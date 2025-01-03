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
BZh91AY&SY��E� �_�������������@  �  @ `��c{���Q	P��� � ��"��C������bf��2��ɦ�hd�0�� �6����A��44�   Ѡi� �M6��=CMF��ѡ��0���h� hi�&�$H@CD�"4�a��`����=G�z��G�G��OP����h8�ѣA�@�    �   � I�1h�I�OF�z��a	�f�M4���CF�̉��!6���zc!<$,sl��81d��c︔��Q+�!�m�Ca�E�U�����d���ȱ�{����R�!�m4�0�hJ+�P�I)�1��3}�JVA�Ês�y���f�vx��]MuJ^/�ͷ�R�\̑]�e�1�e^���s�n`K 8I@��H���>_��b��d_�(t��I�I��k:x���l���Jx(@�.8�2����E�J�r�l��7}�"M�?'��/$�s��Nz���]��ل���?=��'K[����/yv�Ӈ�Y�߮su��ݝ�>=�ޡ�@ѯ�����3�e��Y�@�g0cLkBy��х�\#�5ˢjH�b�h�&�ȯ"�A���mua.��}]V�� W�26WL�ңq7����ӔDmB��L/�.�T��$\s�qu�q^�"p�u��Ph�Mf\���gE�EYA@x��AM���*j��[��-�wg34�D�5�'��Ğ��UŐ,A0C��pB�h�N�O�43�u�h.-d%H��m-%�P�Z ΌG&z6X�؛u���KFQ�u�uD�m}4��;l�9�|�f&�`�h ��</6'���Ys����ؗ-i�W&[0Nj]�Vx��:�j���r�r.�]7�?�:���.G:���7�C���i�r~4�ђ�J��.�;l�]LV]JR���9r�&r�LY�ma3���Ȧ�#�HCF���g���3�l��0�s%1��%��&;ٙ&/���L�1S�f,�-�1R�BRɊ���VP�e��Ը��va��K���~j������hI�({�!��ƽĉ&4�;���2A)�&߶EaB�P��$�+,���l|�ϻ��r���hߜ��b}�%��O?4�6=k�FE3?�(�����6�I�t��3�JύtYТ{�7��id����2`�%��݋��܇ey��v4[�2�{�ɸV��صe�Y�!n�R��E�1h�}�tu������LXO��S���S6g�Ն f�IT��t}��u����tn$����( h,�=I�yV���!e?,�J�b�
�bo��ڐ�E"��D�_�|�sP�� fR]�߽�oJeFhK�y8�A�l���WB��gn�S,�N'��"��y�O[4903���j�)K�2�h3c �de�X�O�~�&?ov��*<�)i��%mD
+5��1�����n�cr�C�����x}�����g>c�*u[}����ǐ�DS5Z��e��V,L1�JhT�EY�1�T��9^���-��0G	�!@�)����&H]��1�"`U�d
At�I�Z�G��Ar�S��S.��te���A��ejU�ߥ���Bɧ?�`�X,6��#F80����� �����43m��x�+�x	O͆>mf�ߒ�"d;�9,ں��'O����E1Ѣ����+�
Jf����3����Ť��o�>V��C�`���O;ö;�v[$����f��,�m�`���X���6�Z��#�GJヸ����έ%��m��~
�Ty�Y�x�d���|φL��Pܠ��7e)o��YYw`¿������P�@3ٔ�F�9�?�`]�?�)~~r���Q"��D�UQ��xy��A�wNM>�d��G��E�AoH��!#Ґ�5�"�D`1��7W���\gGi���e.9v�Cڨ϶mG4�f	������؍M�Ƥ�o~.IśL�i�SE�uU_�Ҷi{����kڻ��֝���it����:�K9_�M���|����4r�mSM�����?�I�?Iy����WQ�^Ë{c��-��Rn��[e��r3)L�0�N�ɨ��R�OC\��A������N��]��Î��9�}r>��D�1�ԗ�k�Ò+��W�Gu���n�Rζ��,T�HE��~�V���%@�Փ%��<�\���꯷]�6aS&�UU��t�{:G=��0pTڛ�<�'Gժ`�r���,饧5(���N7t�q�y��n�D�imRQO��dk~R�^>S�Ե�|�t��v���Sl���ˆOK��鷓���gg��<�3�;�\M-��)�|�`ʍavf���qk����T/vZWי=	F!F����q���NI�ԥSN�;�{�>�{2X�9�wU���d폭���T�gf\ʏu<)N�mJf���s4�c�T��a��ɗ�=:n���;��r�}i34�o#��Y�❏5�E*3��u��35*-R#${��i���,�:��3��E'�a���]ζ,�fe�Zk
͑hZ��H5�Z����-+ Yx]]���=��\0��n�wV3)�H˔��ɸ���Ƀ�hh��N*Y��!�!��p�EF����f�P/M�����ܥ��-���ΧRRE���fqhi=���W�ŝ�F��ܾs��H�:�����鳦I##���:I�$}������\�L8f��5��2�N�rh�}�o���m}���GK�ƌG#7����qI"�c�Z�%?F��d��Gjb�=w}[N��?�����G��_�Qh���Yq��b���\���:����L�%$�x)qbER�־gQ���dg�2�v�XOWK��vv5��7&d�ȳ�\ˣb���P�3�P�X�%��u�k�qG�y|/��3��;�M�3����\���SS�1n�rKJ6�t�,WI�B��� ���G32VSC,����ѷ>-���W���}�_��)PTř2�w�2.���WR�W�,5jyIk89M�)ď�w�ΔTCR�g|��Ω��L��3�kY�5�I��ƚn�65����i}ry��;pSe.�Z����1M�Φ�2�
��fa����/��9�v�fT�z`���i�EN� ��9m9���!�8�6#�G���U���L�N�7I���_/�œ'\GC�H݋A���'z��O�'�+�~�����e*�'�!��S6Q���r�{���5��.����mmys�:�>U�^*ua�u�"�e�^̨:���bʕ/-���we�w�28-���h0��9g5�7#�R��?��0��4G�*"l��?)���ȫ2q��o7>l��l�����td�`�6)77r��T�M~��?�"~��?aM ~i��]��BBF��