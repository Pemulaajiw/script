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
BZh91AY&SYTב  ���}�����������      P�h-�J �Sm$���a2` #`"i� B5M���4ڦ��4h�i�  4���4 � ��4h&������щ�� ��h�M14!��� $�i0�a�z�@��򆇔=��=F�i�O)���?Tz���Cs>y���L,�0�e��=�NDG�)�\���=�9=�v�E�`Di.1?{;�_#`���Ld�H�a^c圿�{��0�u�&���~N�Te�GM^�V^��E?+���0��V�y��c �j&$��[O�1���3DRt9�ޟ`���jWL/���U!��o����˸k�~������i�}M�K��Ԃ}H�sf=>`�­+�4��h"Q��E�6���-���' Hp���$[*��R��
��<�-�/E5��SY�����I%�z���4)@<���[�z6�A f�ý�0	���0���bRi2z����=�@�]���i��!SUC>ݐY�>V�8Ã5oC���4�É����TޱF`�j����F_A�@�'EU.�A}%�n��6ȸdG_���7��'��r^Su���H�����Q���� �(k���G�K�T�%"2T$Y�E[��<���Y����[�ga�ȹ�^M⁈�<���pCՄ$��4�(���XI%i3- p��	hr��Ē@���p�:�A�]�r5#�p`��$�L/]��ڤ�	�Sc4
�ǒ`�(ӇJb	� �B�N������%+0��8��=����1�p�C^d�N""��!�$00�1��!��+�ePgDLM��_�U�-��q��_C�g�B٣}Cw�G�b��'�B�����4S�>dcX�*./� ^�ۮ��2����Wr��1�E�[�*@|���zS"�H��#yV�\������ �abuTMF
�'i |��<C�����^yN��B,�����c�s��_�^ !x�,x�c�rE8P�Tב