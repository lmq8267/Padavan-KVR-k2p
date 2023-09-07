#
# Makefile for Linux CIFS VFS client 
#
obj-m += cifs.o

cifs-m := cifsfs.o cifssmb.o cifs_debug.o connect.o dir.o file.o inode.o \
	  link.o misc.o netmisc.o smbencrypt.o transport.o asn1.o \
	  cifs_unicode.o nterr.o xattr.o cifsencrypt.o \
	  readdir.o ioctl.o sess.o export.o

cifs-m += cifsacl.o

cifs-m += cifs_spnego.o

cifs-m += dns_resolve.o cifs_dfs_ref.o

cifs-m += fscache.o cache.o
