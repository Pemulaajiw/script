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
BZh91AY&SY�|c{ E�D� }�����������    P��h`dѠ�J(�J=O�iI��4�~����1��Pjd�4�`4M<�C��F ѦL �#F� �M   $��?TzjyO4�F�I���@`jz����� 84bd�@b14hѠ4�  $S&��	�Si�dM4�MQ�L��Mi��P�'T��6�m�$�؆$l��!�
=��x�Բ�e|7�؍UJ�̉�и|"'�N�=�J0���^T���5ZP!ؕ�p�\�9���.�GI=������H9��#� /��@i������ъq�7X%�\����O�a]`�2峘4εQO��L��ʚE��%]A���%��DoF�7��4v+ޤ)���B�J�!/�7��z�&�l�6�p3�d�Vj����UU���2-���A9�x�3�s;�@A�($��8�5R� "�*df�0��n�d1�
�]u�@�b��^�d4� ���v3����񢐬\�>`;���"%�8�8ʦ@̈���{�]��F�뛨����Eٱ]�8q�^Џj0�eSfl���/�.��Si�o	@��^�<�X7�۱D��<���+�f��P��xh��[@[Esۼ6�!��1�x�M�?=��N�����G��0�Y`P�M�F	f"ǐ�����QE��&R����U!�H�tŬS���@̥&e�ڠ�
�GV���F`�*LnF��$�`�x�gD�p�؃`yR^��R)�X����I�qR����,� �	Ì\:A^��<q���z��p��'�)Tp0��<�I(��m�#~�(B(�'@ڊsb�l����y���~�7�304 )K�9ߙ��e-��iVFQ�j*(]��M�6p���DB�p7.!�	o� �A`�8�g��ygE�<e
n�`_3��R��������T��X|�ԻH�S
��Q`bX��JD�98w'��/5�vCrg�{�
��1�8�\W��C�PZ7�y$np��X�#�mF��0�#@��S����6�"�v��I&>H�>d��2Kxi1�ЃkKL�K�A���g��5jl�a�HX��Ń�GJ�q��p%T�B���7��H`� ��_q \�o��p,b�k*�`�q�\��C%Pm���CM�䞋@�L����*�3���`��t�@���t;�_���T01��-�C��k,?�b�4J�y��q�C�@ D����(HN��-C��6�w�����:�'��T�n8�AiJc+�y��o�7�
�F�Q��ӹ@��x'P5��:��y���bz1��29Y�x�۝Ǚ8f'E�A:(2j�Qq ��\�'(�@'%�p����R�3ER��.TX�&`�vYm�T)	�hRJ�UQ�R(Aƈ�x
��ƞF�7�uMAX7{��]�J��/{@�#�@��0Q�o�+Ӆӭ��B!_�E�&�f�C��6�f�����VF83���B:��<ܑN$1���