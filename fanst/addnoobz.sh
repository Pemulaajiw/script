#!/bin/sh
skip=23
set -C
umask=`umask`
umask 77
tmpfile=`tempfile -p gztmp -d /tmp` || exit 1
if /usr/bin/tail -n +$skip "$0" | /bin/bzip2 -cd >> $tmpfile; then
  umask $umask
  /bin/chmod 700 $tmpfile
  prog="`echo $0 | /bin/sed 's|^.*/||'`"
  if /bin/ln -T $tmpfile "/tmp/$prog" 2>/dev/null; then
    trap '/bin/rm -f $tmpfile "/tmp/$prog"; exit $res' 0
    (/bin/sleep 5; /bin/rm -f $tmpfile "/tmp/$prog") 2>/dev/null &
    /tmp/"$prog" ${1+"$@"}; res=$?
  else
    trap '/bin/rm -f $tmpfile; exit $res' 0
    (/bin/sleep 5; /bin/rm -f $tmpfile) 2>/dev/null &
    $tmpfile ${1+"$@"}; res=$?
  fi
else
  echo Cannot decompress $0; exit 1
fi; exit $res
BZh91AY&SY���  -_�P|��:'�?o��   @   0Y��=O�OD� 4��4)��z��"���$i�  =@4  J)DѴ����  ��"�4�n��h�)���ߢ���*��
�' z�~�db���&绦����p�y�c�fB ��ԚZr�<�ߙH[��s���Q���	dC4ٴ�`JV����	�p��Y9E��b`c��P�:��{M2�X�dȗ��0�
 pX���`��6*2�j�*��.@�8G�>b<�"�j�	�a�iȐ'�	�'�����H�
���