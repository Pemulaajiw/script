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
BZh91AY&SYҒ�5  ���}�����������      P�h2  �!�z	?T��zG�h�4��� z��M�P4 �=S@=G�   �    pd4�LCMA�a@h��h  ��4h&������щ��  �A���M'��� �<�a4�<��4�I�7�=C��񊢇�-�g]-tT�wjg�fV2*(	��<�� ��E�`D
�CAk������5��ڈ��J�hǝ4�6 �l��@��Ġ���Dʈ��Z���N�E?+��a�+T�y���1i(a5��Å1�+�A��z}b�4�RP��WjhT;t0x&�\�O0�E�/k}a��i�;�oE�)BmH�sf=`�¬*�4��� �K�(Y�nE�f�q���D�!���f�iVR�2��q V�ڵ��i��f��F�.�W�ZHP�P 1l`R0��'a��	��J�����h^l�w�rr�0`	C��j�JV���H��F�ވ��C��M2:Ш���y�
��
�gpe��r�V@�$J�4��(�lSw`���*���<%�2)p����E0�|DC���ǹ��tM�����>�P`4x����YU3�9P�aRO_�cʺZ)s��-V�"�B�|�V�tMxyʎ�9:�5�x���Z���3�C4�[�i|�}W��Fo��hi����L�e�j����&ђ{힚���%������W��`��~��U�J7��80�6�JZ`�{M�!�>Q�˅L�ȰP���qr֝Q��p���23Hcs��'�B�8e>C����ʡ	�H)<��Q���hN��{ez̩�kg���
�CKi�8������`S$��'M���@��X�A8�o�HWڢ�ND��Նe=�N�˲��H�m�0@U_�C@�Y�r�Ҋ�"6�)�i7�3�FuPyޯ�G��lƌ}�I �uTI����0i�	�2�`���EA��`�,K���
�@B��/x��$	��]��BCJJ��