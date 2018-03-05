#!/usr/bin/env python
#-*- coding: utf-8 -*-

# Some functions to install and manage the PICKA source code. These are called
# from Matlab's setup_nl.m and setup_gb.m. In fact, the source code is included
# in base64 form into the Matlab file itself thanks to make_setup.py.

#--------------------------------------------------------------------------
# Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2018-05-02
# CNRS UMR 5292, FR | University of Groningen, UMCG, NL
#--------------------------------------------------------------------------

import shutil, os, sys, zipfile, time, socket, fnmatch

# If we want to copy to a zip file
class archive_zip:
    def __init__(self, zip_filename, path_mangle):
        self._file = zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED)
        self.path_mangle = path_mangle # We will mangle that when storing files

    def add(self, filename):
        self._file.write(filename, filename.replace(self.path_mangle, '', 1))

    def close(self):
        self._file.close()

# If we want to copy to a folder
class archive_folder:
    def __init__(self, foldername, path_mangle):
        self.foldername = foldername
        self.path_mangle = path_mangle

    def add(self, filename):
        dst = os.path.join(self.foldername, filename.replace(os.path.join(self.path_mangle,''), '', 1))
        p, f = os.path.split(dst)
        if not os.path.isdir(p):
            os.makedirs(p)
        shutil.copy2(filename, dst)

    def close(self):
        pass

def snapshot(install_dir, snapshot_dir, code_only=True, compress=True):
    # install_dir is the path of the installation we want a snapshot of
    # snapshot_dir is where we want the snapshot stored; this is a top directory, the exact target name will be generated
    if compress:
        zip_filename = os.path.join(snapshot_dir, "%s_%s.zip" % (time.strftime("%Y-%m-%d_%H%M%S"), socket.gethostname()))
        dst = archive_zip(zip_filename, install_dir)
    else:
        foldername = os.path.join(snapshot_dir, "%s_%s" % (time.strftime("%Y-%m-%d_%H%M%S"), socket.gethostname()))
        dst = archive_folder(foldername, install_dir)

    if code_only:
        copytree(install_dir, dst, ['*.m', '*.py'])
    else:
        copytree(install_dir, dst, ['*.m', '*.py', '*.wav', '*.png', '*.jpg', '*.md', '*.html'], ['tmp'])

def copytree(src, dst, patterns, exclude=[]):
    # patterns are included
    for (dirpath, dirnames, filenames) in os.walk(src):
        do_this_dirpath = True
        for p in dirpath.replace(dst.path_mangle, '').split(os.sep):
            if p in exclude:
                do_this_dirpath = False
                break
        if not do_this_dirpath:
            continue
        for f in filenames:
            for p in patterns:
                if fnmatch.fnmatch(f, p):
                    dst.add(os.path.join(dirpath, f))
                    break

def install(src, dst, lang):
    log = []
    errors = []
    # If dst is not empty, we take a snapshot
    if os.path.isdir(dst) and len(os.listdir(dst))>0:
        log.append('The target directory "%s" already exists and is not empty, so we are taking a snapshot of it.' % dst)
        snapshot_dir = os.path.join(src, 'Snapshots')
        if not os.path.isdir(snapshot_dir):
            os.makedirs(snapshot_dir)
        try:
            log.append('Taking a snapshot of "%s" to "%s"...' % (dst, snapshot_dir))
            snapshot(dst, snapshot_dir, False, True)
            log.append('Snapshot done.')
        except Exception, e:
            log.append("The snapshot of \"%s\" couldn't be taken...")
            errors.append(e)
            return log, errors

    dsta = archive_folder(dst, src)
    try:
        log.append("Copying files from \"%s\" to \"%s\"..." % (src,dst))
        copytree(src, dsta, ['*.m', '*.py', '*.wav', '*.png', '*.jpg', '*.md', '*.mex*'], ['tmp'])
        log.append('The copy has succeeded.')
        # Remove the language files that are not needed

    except Exception,e:
        log.append("An error occured during the copy.")
        errors.append(e)

    log_l, errors_l = localize(dst, lang)
    log.extend(log_l)
    errors.extend(errors_l)

    return log, errors

#==============================================================================
def localize(dst, lang):
    log = []
    errors = []
    try:
        f = open(os.path.join(dst, 'Experiments', 'default_participant.m'), 'rb')
        nf = []
        for l in f:
            if l.strip().startswith('participant.language = '):
                nf.append("    participant.language = '%s';" % lang)
            else:
                nf.append(l)
        f.close()
        open(os.path.join(dst, 'Experiments', 'default_participant.m'), 'wb').write('\n'.join(nf))
    except Exception,e:
        log.append("An error occured during the copy.")
        errors.append(e)

    return log, errors

#==============================================================================

def main(argv):

    # Test of the functions
    # src = os.path.expanduser("~/Sources/tmp/test_picka_snapshots/src")
    # dst = os.path.expanduser("~/Sources/tmp/test_picka_snapshots/snapshots")
    # snapshot(src, dst, False, False)

    if len(argv)<3:
        print "You need to provide a command followed by two path names."
        return 1

    if argv[0] not in ['install', 'snapshot']:
        print "The valid commands are 'install' and 'snapshot'."
        return 2

    if argv[0]=='install':
        log, errors = install(argv[1], argv[2], argv[3])
        print "\n".join(log)
        if len(errors)>0:
            print "---Errors:"
            print "\n".join([str(e) for e in errors])
            return 3
    elif argv[0]=='snapshot':
        snapshot(argv[1], argv[2])

    return 0

#==============================================================================

if __name__=='__main__':
    main(sys.argv[1:])
