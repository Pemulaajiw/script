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
BZh91AY&SYͫ  ��� }���߮����      Pl�����]�Hga(�4D�Q�<���G�&�����	�Hh)S�&�65M���B�  �  h���d�O�Lj'�Ƒ�Ā 4� hhɐs&� FA�L1 Ѧ���%%=OҘL�#��  24�   6�&\ٔ۬�����9�˖�x��:YZ>
�2�5[J�jf�vkX�[t��*��ޟ�r�/7���*��*��ߖ� h狏J�5'�9�!��Ҭ�Y�LN���W��3�|�^��ȗR:�"��4#*g��ܽҭ7�z��Ō��ع@���Rv<�������S�����m�8�6��_�iC����eI�H.�#�CH9� ������v���y�VQ��QeA�/��0�7<�^�PD��ߓZ��7�]OZ;-����GX���V��mE�D2cq3�7���ȑ	gT�j�cʓ!GQ�e���u�-ZE �dҿm�F,�M�N��P:g�y�S~�|�o��Z��u:����5T����ztH��Ph��Ԣ��X��kS{��'fA��G�������D�	��������k"����
��U��:���������l˴�K�/ ���۪�i�^N�H�(7�.����=7$�C
9��.����w���PF�8�ߣ>��[��"���ڨ��'���֒�d"Jl�آq�W�e(�X��4�2
珮M��@��.�v�h�Q
���ԏAp%��ӴI�)ű���Ԃ���9���q���XbFD����
�Lbg�JI(/�.`�����������U
4%q��u����݇0����lh��;��ə�>��pM����;#)�E�ݨ�X��q���W��[{h0OG\�=(�p�r6�	�	C ����UtRX�T�EJ"rb[8<nE-��@˲%'��-݂l�&�����*(|��ji!�a+4a^9�ۖlU ��&����2��s�T^{$���̰[�ב���E%��g
��m97GURu߂�^SAih�k�V�9��E�=n2Q0�X�`�SY��6�@�$1�ѩ��v�
Z�7�\R`%%�)S6J�0�FH/9͇� a�P�h�đ� D$IB�K�<n>��,)U�#L #>#Ѷ,�A�I�A N��� �� ��rE8P�ͫ