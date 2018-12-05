#!/usr/bin/python2

# Copyright (C) 2001 Matt Zimmerman <mdz@debian.org>
# Copyright (C) 2007,2011 Javier Fernandez-Sanguino <jfs@debian.org>
# - included patch from Justin Pryzby <justinpryzby_AT_users.sourceforge.net>
#   to work with the latest Lsof - modify to reduce false positives by not
#   complaining about deleted inodes/files under /tmp/, /var/log/,
#   /var/run or named   /SYSV. 
# - introduced a verbose option

# PENDING:
# - included code from 'psdel' contributed by Sam Morris <sam_AT_robots.org.uk> to
#   make the program work even if lsof is not installed
#   (available at http://robots.org.uk/src/psdel)
# - make it work with a whitelist of directories instead of a blacklist
#   (might make it less false positive prone)
# 
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, 
# MA 02110-1301 USA
#
# On Debian systems, a copy of the GNU General Public License may be
# found in /usr/share/common-licenses/GPL.

import sys
import os, errno
import re
import pwd
import sys
import string
import subprocess
import getopt
from stat import *

if os.getuid() != 0:
    sys.stderr.write('ERROR: This program must be run as root in order to obtain information\n')
    sys.stderr.write('about all open file descriptors in the system.\n')
    sys.exit(1)

def find_cmd(cmd):
     dirs = [ '/', '/usr/', '/usr/local/', sys.prefix ]
     for d in dirs:
         for sd in ('bin', 'sbin'):
             location = os.path.join(d, sd, cmd)
             if os.path.exists(location):
                 return location
     return 1

def usage():
    sys.stderr.write('usage: checkrestart [-vhpa] [-bblacklist] [-iignore]\n')

def main():
    global lc_all_c_env, file_query_check
    process = None
    toRestart = {}

    lc_all_c_env = os.environ
    lc_all_c_env['LC_ALL'] = 'C'
    file_query_check = {}
    blacklistFiles = []
    blacklist = []
    ignorelist = [ 'util-linux', 'screen' ]

# Process options
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hvpab:i:", ["help", "verbose", "packages", "all", "blacklist", "ignore"])
    except getopt.GetoptError, err:
        # print help information and exit:
        print str(err) # will print something like "option -x not recognized"
        usage()
        sys.exit(2)

    # Global variables set through the command line
    global verbose, onlyPackageFiles, allFiles
    verbose = False
    # Only look for deleted files that belong to packages
    onlyPackageFiles = False
    # Look for any deleted file
    allFiles = False

    for o, a in opts:
        if o in ("-v", "--verbose"):
            verbose = True
        elif o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-p", "--packages"):
            onlyPackageFiles = True
        elif o in ("-a", "--all"):
            allFiles = True
            onlyPackageFiles = False
        elif o in ("-b", "--blacklist"):
            blacklistFiles.append(a)
            onlyPackageFiles = False
        elif o in ("-i", "--ignore"):
            ignorelist.append(a)
        else:
            assert False, "unhandled option"

    for f in blacklistFiles:
        for line in file(f, "r"):
            if line.startswith("#"):
                continue
            blacklist.append(re.compile(line.strip()))

# Start checking

    if find_cmd('lsof') == 1:
        sys.stderr.write('ERROR: This program needs lsof in order to run.\n')
        sys.stderr.write('Please install the lsof package in your system.\n')
        sys.exit(1)
# Check if we have lsof, if not, use psdel
#    if find_cmd('lsof'):
#         toRestart = lsofcheck()
#    else:
# TODO - This does not work yet:
#        toRestart = psdelcheck()

    toRestart = lsofcheck(blacklist = blacklist)

    print "Found %d processes using old versions of upgraded files" % len(toRestart)

    if len(toRestart) == 0:
        sys.exit(0)

    programs = {}
    for process in toRestart:
        programs.setdefault(process.program, [])
        programs[process.program].append(process)

    if len(programs) == 1:
        print "(%d distinct program)" % len(programs)
    else:
        print "(%d distinct programs)" % len(programs)

# Verbose information
    if verbose:
        for process in toRestart:
            print "Process %s (PID: %d) "  % (process.program, process.pid)
            process.listDeleted()

    packages = {}
    diverted = None
    packageCount = -1
    dpkgQuery = ["pacman", "-Qoq"] + programs.keys()
    dpkgProc = subprocess.Popen(dpkgQuery, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                env = lc_all_c_env)
    if verbose:
        print "Running:%s" % dpkgQuery
    while True:
            packageCount = packageCount + 1
            line = dpkgProc.stdout.readline()
            if not line:
                break
            if verbose:
                print "Reading line: %s" % line
            if line.startswith('local diversion'):
                continue
            #if not ':' in line:
            #    continue

            m = re.match('^diversion by (\S+) (from|to): (.*)$', line)
            if m:
                if m.group(2) == 'from':
                    diverted = m.group(3)
                    continue
                if not diverted:
                    raise Exception('Weird error while handling diversion')
                packagename, program = m.group(1), diverted
            else:
                 packagename = line
                 program = programs.keys()[packageCount]
                 sys.stdout.write ('package: %s program: %s' % (packagename, program))
                 if program == diverted:
                     # dpkg prints a summary line after the diversion, name both
                     # packages of the diversion, so ignore this line
                     # mutt-patched, mutt: /usr/bin/mutt
                    continue
            packages.setdefault(packagename,Package(packagename))
            try:
                 packages[packagename].processes.extend(programs[program])
            except KeyError:
                  sys.stderr.write ('checkrestart (program not found): %s: %s\n' % (packagename, program))
            sys.stdout.flush()

    # Close the pipe
    dpkgProc.stdout.close()

    print "(%d distinct packages)" % len(packages)

    if len(packages) == 0:
        print "No packages seem to need to be restarted."
        print "(please read checkrestart(1))"
        sys.exit(0)

    for package in packages.values():
        skip = False
        if ignorelist:
            for i in ignorelist:
                if i in package.name > 0:
                    skip = True
        if skip:
            continue
        dpkgQuery = ["pacman", "-Qlq", package.name]
        dpkgProc = subprocess.Popen(dpkgQuery, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                env = lc_all_c_env)
        while True:
            line = dpkgProc.stdout.readline()
            if not line:
                break
            path = line[:-1]
            if path.startswith('/etc/init.d/'):
                if path.endswith('.sh'):
                    continue
                package.initscripts.add(path[12:])
            sys.stdout.flush()
        dpkgProc.stdout.close()

        # Alternatively, find init.d scripts that match the process name
        if len(package.initscripts) == 0:
            for process in package.processes:
                proc_name = os.path.basename(process.program)
                if os.path.exists('/etc/init.d/' + proc_name):
                    package.initscripts.add(proc_name)
    if not verbose:
	sys.exit(0)
    restartable = []
    nonrestartable = []
    restartCommands = []
    for package in packages.values():
        if len(package.initscripts) > 0:
            restartable.append(package)
            restartCommands.extend(map(lambda s: 'service ' + s + ' restart',package.initscripts))
        else:
            nonrestartable.append(package)
            
    if len(restartable) > 0:
        print
        print "Of these, %d seem to contain init scripts which can be used to restart them:" % len(restartable)
        # TODO - consider putting this in a --verbose option
        print "The following packages seem to have init scripts that could be used\nto restart them:"
        for package in restartable:
              print package.name + ':'
              for process in package.processes:
                   print "\t%s\t%s" % (process.pid,process.program)
                    
        print
        print "These are the init scripts:"
        print '\n'.join(restartCommands)
        print

    if len(nonrestartable) == 0:
        sys.exit(0)

    # TODO - consider putting this in a --verbose option
    print "These processes do not seem to have an associated init script to restart them:"
    for package in nonrestartable:
        skip = False
        if ignorelist:
            for i in ignorelist:
                if i in package.name > 0:
                    skip = True
        if skip:
            continue
        print package.name + ':'
        for process in package.processes:
            print "\t%s\t%s" % (process.pid,process.program)

def lsofcheck(blacklist = None):
    processes = {}

    for line in os.popen('lsof +XL -F nf').readlines():
        field, data = line[0], line[1:-1]

        if field == 'p':
            process = processes.setdefault(data,Process(int(data)))
        elif field == 'k':
            process.links.append(data)
        elif field == 'n':
            # Remove the previous entry to check if this is something we should use
            if data.startswith('/SYSV'):
                # If we find SYSV we discard the previous descriptor
                last = process.descriptors.pop()
            elif data.startswith('/'):
                last = process.descriptors.pop()
                # Add it to the list of deleted files if the previous descriptor
                # was DEL or lsof marks it as deleted
                if re.compile("DEL").search(last) or re.compile("deleted").search(data) or re.compile("\(path inode=[0-9]+\)$").search(data):
                    process.files.append(data)
            else:
                # We discard the previous descriptors and drop it
                last = process.descriptors.pop()
        elif field == 'f':
            # Save the descriptor for later comparison
            process.descriptors.append(data)

    toRestart = filter(lambda process: process.needsRestart(blacklist),
                       processes.values())
    return toRestart

# Tells if a given file is part of a package
# Returns:
#  - False - file does not exist in the system or cannot be found when querying the package database
#  - True  - file is found in an operating system package
def ispackagedFile (f):
    file_in_package = False
    file_regexp = False
    if verbose:
        print "Checking if file %s belongs to any package" % f
    # First check if the file exists
    if not os.path.exists(f):
        if ( f.startswith('/lib/') or f.startswith('/usr/lib/') ) and re.compile("\.so[\d.]+$"):
        # For libraries that do not exist then try to use a regular expression with the
        # soname
        # In libraries, indent characters that could belong to a regular expression first
            f = re.compile("\+").sub("\+", f)
            f = re.compile(".so[\d.]+$").sub(".so.*", f)
            f = re.compile("\.").sub("\.", f)
            file_regexp = True
        else:
        # Do not call dpkg-query if the file simply does not exist in the file system
        # just assume it does not belong to any package
            return False

    # If it exists, run dpkg-query
    dpkgQuery = ["pacman", "-Qoq", f ]
    dpkgProc = subprocess.Popen(dpkgQuery, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                env = lc_all_c_env, close_fds=True)
    dpkgProc.wait()
    if verbose:
        print "Running:%s" % dpkgQuery
    for line in dpkgProc.stdout.readlines():
        line = line.strip()
        if line.find('no path found matching pattern ' + f) > 0:
            file_in_package = False
            break
        if line.endswith(f) or ( file_regexp and re.search(f, line)):
            package  = re.compile(":.*$").sub("",line)
            file_in_package = True
            break

    if file_in_package and verbose:
        print "YES: File belongs to package %s" % package
    if not file_in_package and verbose:
        print "NO: File does not belongs to any package" 
    return file_in_package

# Tells if a file has to be considered a deleted file
# Returns:
#  - 0 (NO) for known locations of files which might be deleted
#  - 1 (YES) for valid deleted files we are interested in
def isdeletedFile (f, blacklist = None):

    global lc_all_c_env, file_query_check

    if allFiles:
        return 1
    if blacklist:
        for p in blacklist:
            if p.search(f):
                return 0
    # We don't care about log files
    if f.startswith('/var/log/'):
        return 0
    # Or about files under temporary locations
    if f.startswith('/var/run/'):
        return 0
    # Or about files under /tmp
    if f.startswith('/tmp/'):
        return 0
    # Or about files under /dev/shm
    if f.startswith('/dev/shm/'):
        return 0
    # Or about files under /run
    if f.startswith('/run/'):
        return 0
    # Or about files under /drm
    if f.startswith('/drm'):
        return 0
    # Or about files under /var/tmp
    if f.startswith('/var/tmp/'):
        return 0
    # Or /dev/zero
    if f.startswith('/dev/zero'):
        return 0
    # Or /dev/pts (used by gpm)
    if f.startswith('/dev/pts/'):
        return 0
    # Or /usr/lib/locale
    if f.startswith('/usr/lib/locale/'):
        return 0
    # Skip files from the user's home directories
    # many processes hold temporafy files there 
    if f.startswith('/home/'):
        return 0
    # Skip automatically generated files
    if f.endswith('icon-theme.cache'):
        return 0
    # Skip font files
    if f.startswith('/var/cache/fontconfig/'):
        return 0
    # Skip Nagios Spool
    if f.startswith('/var/lib/nagios3/spool/'):
        return 0
    # Skip nagios spool files
    if f.startswith('/var/lib/nagios3/spool/checkresults/'):
	return 0
    # Skip, if asked to, files that do not belong to any package
    if onlyPackageFiles:
        # Remove some lsof information from the file to ensure that it is
        # a proper filename
        file_name = re.sub(r'\(.*\)','', f)
        file_name = re.sub(r'\s+$','', file_name)
        # First check: have we checked this file before? If we have not then make the check
        if not file_name in file_query_check:
                file_query_check[file_name] = ispackagedFile(file_name)
        # Once we have the result then check if the file belongs to a package
        if not file_query_check[file_name]:
                return 0

    # TODO: it should only care about library files (i.e. /lib, /usr/lib and the like)
    # build that check with a regexp to exclude others
    if f.endswith(' (deleted)'):
        return 1
    if re.compile("\(path inode=[0-9]+\)$").search(f):
        return 1
    # Default: it is a deleted file we are interested in
    return 1

def psdelcheck():
# TODO - Needs to be fixed to work here
# Useful for seeing which processes need to be restarted after you upgrade
# programs or shared libraries. Written to replace checkrestart(1) from the
# debian-goodies, which often misses out processes due to bugs in lsof; see
# <http://bugs.debian.org/264985> for more information.

    numeric = re.compile(r'\d+')
    toRestart = map (delmaps, map (string.atoi, filter (numeric.match, os.listdir('/proc'))))
    return toRestart

def delmaps (pid):
    processes = {}
    process = processes.setdefault(pid,Process(int(pid)))
    deleted = re.compile(r'(.*) \(deleted\)$')
    boring = re.compile(r'/(dev/zero|SYSV([\da-f]{8}))|/usr/lib/locale')

    mapline = re.compile(r'^[\da-f]{8}-[\da-f]{8} [r-][w-][x-][sp-] '
            r'[\da-f]{8} [\da-f]{2}:[\da-f]{2} (\d+) *(.+)( \(deleted\))?\n$')
    maps = open('/proc/%d/maps' % (pid))
    for line in maps.readlines ():
        m = mapline.match (line)
        if (m):
            inode = string.atoi (m.group (1))
            file = m.group (2)
            if inode == 0:
                continue
            # remove ' (deleted)' suffix
            if deleted.match (file):
                file = file [0:-10]
            if boring.match (file):
                continue
            # list file names whose inode numbers do not match their on-disk
            # values; or files that do not exist at all
            try:
                if os.stat (file)[stat.ST_INO] != inode:
                    process = processes.setdefault(pid,Process(int(pid)))
            except OSError, (e, strerror):
                if e == errno.ENOENT:
                    process = processes.setdefault(pid,Process(int(pid)))
                else:
                    sys.stderr.write ('checkrestart (psdel): %s %s: %s\n' % (SysProcess.get(pid).info (), file, os.strerror (e)))
        else:
            print 'checkrestart (psdel): Error parsing "%s"' % (line [0:-1]) 
    maps.close ()

    return process


class SysProcess:
	re_name = re.compile('Name:\t(.*)$')
	re_uids = re.compile('Uid:\t(\d+)\t(\d+)\t(\d+)\t(\d+)$')
	processes = {}
	def get (pid):
		try:
			return Process.processes [pid]
		except KeyError:
			Process.processes [pid] = Process (pid)
			return Process.get (pid)

	# private
	def __init__ (self, pid):
		self.pid = pid

		status = open ('/proc/%d/status' % (self.pid))
		for line in status.readlines ():
			m = self.re_name.match (line)
			if m:
				self.name = m.group (1)
				continue
			m = self.re_uids.match (line)
			if m:
				self.user = pwd.getpwuid (string.atoi (m.group (1)))[0]
				continue
		status.close ()
	
	def info (self):
		return '%d %s %s' % (self.pid, self.name, self.user)

class Process:
    def __init__(self, pid):
        self.pid = pid
        self.files = []
        self.descriptors = []
        self.links = []
        self.program = ''

        try:
            self.program = os.readlink('/proc/%d/exe' % self.pid)
            # if the executable command is an interpreter such as perl/python,
            # we want to find the real program
            m = re.match("^/usr/bin/(perl|python)$", self.program)
            if m:
                with open('/proc/%d/cmdline' % self.pid, 'r') as cmdline:
                    # only match program in /usr (ex.: /usr/sbin/smokeping)
                    # ignore child, etc.
                    #m = re.search(r'^(([/]\w*){1,5})\s.*$', cmdline.read())
                    m = re.search(r'^(/usr/\S+)$', cmdline.read())
                    if m:
                        # store the real full path of script as the program
                        self.program = m.group(1)
        except OSError, e:
            if e.errno != errno.ENOENT:
                if self.pid == 1:
                    sys.stderr.write("Found unreadable pid 1. Assuming we're under vserver and continuing.\n")
                else:
                    sys.stderr.write('ERROR: Failed to read %d' % self.pid)
                    raise
        self.program = self.cleanFile(self.program)

    def cleanFile(self, f):
        # /proc/pid/exe has all kinds of junk in it sometimes
        null = f.find('\0')
        if null != -1:
            f = f[:null]
        # Support symlinked /usr
        if f.startswith('/usr'):
            statinfo = os.lstat('/usr')[ST_MODE]
            # If /usr is a symlink then find where it points to
            if S_ISLNK(statinfo): 
                newusr = os.readlink('/usr')
                if not newusr.startswith('/'):
                    # If the symlink is relative, make it absolute
                    newusr = os.path.join(os.path.dirname('/usr'), newusr)
                f = re.sub('^/usr',newusr, f)
                # print "Changing usr to " + newusr + " result:" +f; # Debugging
        return re.sub('( \(deleted\)|.dpkg-new).*$','',f)

    def listDeleted(self):
        listfiles = []
        listdescriptors = []
        for f in self.files:
            if isdeletedFile(f):
                listfiles.append(f)
        if  listfiles != []:
            print "List of deleted files in use:"
            for file in listfiles:
                print "\t" + file

    # Check if a process needs to be restarted, previously we would
    # just check if it used libraries named '.dpkg-new' since that's
    # what dpkg would do. Now we need to be more contrieved.
    # Returns:
    #  - 0 if there is no need to restart the process
    #  - 1 if the process needs to be restarted
    def needsRestart(self, blacklist = None):
        for f in self.files:
            if isdeletedFile(f, blacklist):
	    	return 1
	for f in self.links:
	    if f == 0:
	    	return 1
        return 0

class Package:
    def __init__(self, name):
        self.name = name
        # use a set, we don't need duplicates
        self.initscripts = set()
        self.processes = []

if __name__ == '__main__':
    main()