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
BZh91AY&SY}�  ���� }���߮����      Pl�=n��7m�;�f��5O)�d��6L��l��z@ځ��z��)�h%2`��ɔ�SOQ= ���i�h4O�0A�24�!4L��ḥ4� � ��h�2i�� �d 4�h � R���ЏPښi���&�   @B}:�.)��t��F�Nu�E�p�r����Y�8�����0�V�"��؛�=�պL	�Ӆ�~=�{t�ɉ��@ �8�aN���@&7�z!�(+ckG0���BDza"��
f�`p�VJ�{|�?��x,ċ����U�U���Zd����{�=�	�2��U������#J,.��vɚN�fy�p�#E����C�NR�1�0��s��I$��G5�ˤ���C6�n������raI���V/~J�Ϣ�XL:O���1+�;��΁�T�*��D>2"җ_�i�3d? ����Z(��>#)���⿍F�&d nS�[6��!����:䦢��u�])�ω8&cV�˾ݥ�f��py�3��C�d����:�К��#�
�-i�H�<��uf1���%��_�ݼ��ܜ�S~�xZ��^���89Y��/��ۣ��f�|q&+\a��S�������D�	)�eSoC"vh[�.5����nLq[!���44K�z�>+�S(H&� xÒ���Bo�v%D,O}��E'L�����f������[@��]�y�Q���`�A^�T'�%�#	Ѵ�Hɑ��6��0Ż�m� ��}�=�t�+A��Y�:�uaR�Xq�Ջ0P
���P�@�h�ޢ�,�4�O��IC1Cya�8�Bhիθ\��c������r���jZ�rHLkm���Y�������%\��|)�.i*��t$�0�(���
�u����I�v��&�(aSrm��ɩ4T��I ���+E��Ȧ�]��Ts��v�)�+8y{^Zʂ�����,cR��f�,�a��D��EHS{	݌�>�����,j�.��9�;�}	�D�˔�j��mRVV�9�Y3$T�C)l��%��V�3���}=�xv{��� �J�v�i�5�T��F�T�!��;�a����1ԣ	r':j�����0�x�ًO6��>!�%������>AY��)�E�
+����/�	 �!$�+�9P
h`�����)���x(