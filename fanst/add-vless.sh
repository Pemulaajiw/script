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
BZh91AY&SY�@76 ��|� �����������    `	�|٢��l�l$�I(J%OȚ�F#�Ѧ���2 � =@ 4� �#C@ )�'���M��zF���M ��z@���L���h�2h 4 �hh�F����h�2h 4 �hh�F����h�2h 4 �hh�F���	��ڙ)��~)?D����C&��� �jz��h='�В
X� a~_�����;��h�/7�b�ן��2�X|��5'���"'yd,+����}k�fXG�vBZ�L19w5�c����5f9�يq��]�F���G3xuЧcG�'���n_��Y��-s�x̳fZ4��_*6�!#6s`d/ �H��Ni�`�%yy�~�5L�� .+I#�i�GGF����������:�cc�6$�%[S �<V�w;b��<�"	8���4�fe���1��]�8F�� X������ke^}g �Y����>��<�Z!��/9 �9�ΒZ��&R4g!�(����v+����d�z$2�%�z�J������IJ�}F�ߤ�Y�ӻW��/CrE2��A4hr�_{/YASD[v`ӤV@FX��N��:��ܽ�����)n]�0�;�F��!��,�ڌ��0Z�6�Y,{\�~Y�!qs�Ўi�
l#���
� ��A��� �<l�u��>"�~@)�A�%�́�a6A��S���frB�V# �LÎB`�A�`߱��_�W�ncl��S	�_!t6�Î�����o�!a���Z0�$3�d�	&Ƿ��+#��癣+�[���wѿث��ti8-���'��v����H�{Σ�<���I�@wrD�!�ؤYNR���li}	�)���ԉ
@��]�_��(k�@�	�`N-X�(���5ߤ���+RTT8d/|�θ <>����T;�=H������<��pqhu]4�H9:׼h��J�*��P`�
�7A�H�J�$���;d[��9f�j��q�;*��Ċ�J1���5�:���q_��>g�i�3�0(�T)L�+�7z��<fO\蠿����Mh�
A�
(�J(�_	;B���w�=�ՠU���5���a����0�����Lj����kٜǣ埶�*|�{ms%F�s<�r��W�\y���x66�|a�Pu�+��(��3�i5����c2p֌����5HYF��βM�A�蔰"PT��g���;���+WI�t��D��"D���B�c`6$��=����������<W���u?J�ch�<F��jG���<� �]b�E�R�A4���'�HH~��xKR�taa�	�q���s%����SC]Gv�"�z<�!���ߑ dG�`��`��\íb�,���ymS��� �X����# ���vൌ�pB��3��*Υ2��<g�Wo ��̂�����Y�F�T1���lS�9&��	��*ǹ�gZ�����wgp�����K,���j���`���U�`���K�`�)�BٔԫH�`��iiP؀ҵs�3�KI� �*CqZj̈́*l�yLSs6:g�$Rlc'���b@b�,��+�}�jfU��=&Ӌ�5.��O:8Q��g�T��
�2iB��"H*�
�l��\%F�q�k��%������Ul��R���,S!w�)�;+��)�܎�L�Y3�e���!��LE6��\n�o�r B��&q�9
�
2�9�,���V|��в*����r��"b��̚��zJ5b(�:�>�ā����*��@��/Hu����T^T��!u��R��e���ƍC2��,�"��œ.ǥ�JCc��#�nL؛?Y"����o�k������ k]u��,r��50�> zV�n��;�-[��"�ȘLɚ/2��b�
�@*�`��?�����jC�H��Y�	�#��oE06��B��r	�����kG�4��z�*h���S�4�ҧ�TBYһv��l�d����"3d��2I���Yr*�Y	�FRB!`�
�O�DZ���(q�YV�*/Iu�K L�P�IP��!Ҋ�,;ED�q@��lZ1�.�45y�n-�	�D�����&�6���2P�|D�k% �Km�/�ll�;��y�A� �]8и�۬U"Tl���K��3i� � )oP���7�  ��^��wv�'�ǅ:�M�0[�T5��|�5u䶎�Y����Q����	���$
�0��b�.�p�!f�nl