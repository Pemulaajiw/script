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
BZh91AY&SY=c�� _�������������@   `q4t �P   BE&J��?E�A��F��&F���ѧ�i��2 �Mi����Tz�@b44   �    �5���	�mG��  h    b� p4 �44 hd4�M � @���4@�����@4@ d1 �HD	��S&�SCM'��<�����ڌ�6�C#�"+A�!�I�I��0�ِ=Q�ťaE�EFM����u*@ڰS���e9b�`���� B2�]30�X���E\Z�:��H�J	IO����O��a��Sb�B��C�kEER�l,�C��/_��E؟��L�G_���"��5C!$~E�D�ò`9���QX�Pl,%e'kR�U�˵k>��3�E��k��p���P�\��x��Fh�K�$`0�YQ�s&Q��%��������%�r.�V�
��hW��ܼ�1n#���\�IŽA�1�v=w\7�}��ᘰ�
��CaB��8�8Nj
�Yf@0�:�� Q�Y��&��� OL 
k�y�WJ�5���NiW�+6kN�s��U\y?�l��1k����&�#T׼�YK�ۏ���W ���7
Y��#I0��u������"���c8Ԕ��JM�?R&�te �����p�7K�y���ʿoQ�5�E6B��(	�n81Јus�2(A��df�	쀐"]��ff�Gh��0�B*7���V07��p����f7ۿ����]K�/OL�|k�a]ܬ��#�M�c/o)��ah��v�S��
>�@q���B�A�I8��gU�������.L����V������u0�����b�݂�.P�Zv?{3qXy�(�KJ��Z��A�<��J�L��S����\��P}59b�9��puiM4���=�ȭ�ѕl!#&A���������[\���D.[6��N�lv��^#���mƓ�p�s��<*�l5��+0Euhj^�y��l�c��d��5��� ��9��*X���]���uw�@	����gAy}���_���$j04̪jy�\F�(�Q�Y�N���K���w��h@�����_e_)*c;�kD�I�b�A�m�5ny� ����g�|�����j��\�1߂�_i�~'�
Bc��T�E���@S�����횤c��^~"L�X��J:��)u�޽<����5�?�a�Y��ԗyy��SFv��o�#\��ABS��ȱ�8�H�(��,�g��:+0r��9AXžЬ��"EǕ����PgBǺu|G�֥��V�j.JB��V�	@�ÔE5��q5��`�Om�r�o ����=�p�а C���LӧD-������ݸ4��(�crN�z.O���$s��e��	��;*�.�1�`4�~;��qk�����HT��������e4�'R�2$�V��TR�!�"����ţ���Z�3�dl�A�9U%�4q���P2>�	��iM#�ɉ*6�YA.�u��lOG0-� �� m[S�;�^RU^��˻5Q�����g��"�Š��rk�7S�1|� ��g�����@�.%��T#M�\������S�+��$@w����@�������K}��kS��ג���H��E�1v�$��F�Z�b�̛S�@A[�2�VMf7�;�Pn<w�@���=�
Օ��,�A	��w��ԑ�T�y�D!�Q�m�7(�&$0ha�,�BR)���VZs����y �b$��� a�iLA�)KF1�|�~Q�;��
�B`=DuaU�S�����j4%� �
�RPH W,���̎ ۑm)�ň�1�3�2q���<Abud�Q6f-P�
���x�����Gp\�a�pi��c�1���A�xS�@�Xv�a�"yq���͠>n�F����<��f�E���!�f8�F�)���Ѥ�d�C��-��xN\�C(E�X�Ē�&搬�N5U3�_ �I�BY�eP{��K�`2_��l��Q1���e��,J��8��Ig�$ GH@��(@�ܑN$X�:�