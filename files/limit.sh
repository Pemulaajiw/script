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
BZh91AY&SY���&  T��}��gYۀ?���      @y�֔R4hɠ#'�h �I��4�ɓF�� �0F`��є��4Ѧ@���2���TI�F2L�i��!�  � z�dW��_&�eqy9ڨ&�mfyl+�+�@g��$�^�TƶL�07�qہ(�����l�-*Gs1\%h��@����Y�!�t���q�SUҙ&T�k�NZW�xm BI$���v��C@P�p�m�zua�VzC��]ܙ9�/�����X,0��	=^�@���@X�8�AL<eb��D�Y�9 =��D������/#i���f�T3Z(]�V���=����?�p@ձ$�I%3:c7+������:�j�j#��5��'}��茘Dv��J��cSDG(/��$�I$�UR.r7 ���GpU���a�&��G,F��#Z��oI����p�4���"�d���)��Q2JV.͓�����h���DT鄖���g�ZF�W�����aqʓ�El���Ͼx��q����"����Mb># �i��{G�B;#���.�A�]��BB�