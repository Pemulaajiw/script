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
BZh91AY&SY,ʷ  "_�Dp}���?oߞ����       @��
 ��OB��4��`��3@&��hi0p�ɦ��dd��&�2db��iz� h�    ��  $� M2
mI���{Tɦ��d���~��	��F,B6��*CB�fOf�4(�`�i�`@�~Nӻ�A� )$��V
���%����I�`s'�L�`3ɮy7"�U�"N�&���-Pڀ:
P��y����Y�Au�Jd���f��hH��6�z�r��,���w�2�Xch��dl�9=C�O�d��K�F�:s.d�}.�UD�ur,U��d��P�#�V�����9�f��fR�2I������3���X$�Rs�	�=�_s7��ݸ62=�l̎8������nG������:��7�B�s�|-���<g*Y��DB&
6�P܄�a eiR1��{�]\�G�$�G��8�/��>>������?�Z�h��=y1�d�iȕ|3S&A�����}�ar��G���[�R�V`cqvu6TaĤ;�
�Z%�v�7�v�qh��������]^��NЧO�)���K�¥Vs0���<:&+�%`��E0`n�+����&���U!PU�p����A����]�ɑ���uL?֎6�.�q�l}]�&�`ʰ�D��˽��γ�U�)h�٤�ml�2�I�����zc���8:���$es)�&�J0�&�Wu��N�Ӗ���.k�ؕ�Q�鸫��b��E͉�jeB����K�$��j��]��rE8P�,ʷ