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
BZh91AY&SY��Ə V�x0 }���}ߎ����      `\>�������R� XiM24�� &�L&��  �4d�hh4��F��� �4��244di�L���  �L���B�Hh����44�#@  �M4�T�z�����&�	���@���(ڃL ��$H#@��4� (=5=A�z �#2�
�M����%�{_���"�)cZ��{[W�r�3.�������؈ҍ��%+���i�Im�(��Gfӑ���]>����XARrjt�]�E���k���*�	�B�I �n���D����}����>���70G����`ٳ�DnH;�st���+�2���GC$Ӥ�۔����j�Q��c*]`�v�g78�6��޿����ͦ�h��oi��cf��gG��l��_��l���;��ģ�QaU��a�LƄ�*�V$a�ˍ\��Wa�M�V�B@e�V�YO+k����O��H���o	_Bt��e�l���bB84s�+� ��I�&!���ͥF���Sz I�HR{\�z%=�!j緟�E��Z���-iJ-��'
�*A9�66�6��i��p�5�龶�HiY �ٗQ�x����:�ۭ+j����_���#����Zɂ4�Lΰ�!�h0�1��y��|� �P?H
�\8B�3�,�j����a��dz�cTy�m�7�	�w)o��S�x�Ȭ	��3@�{��م�K���N@�-ԨOc�ѐ�.S�ݔAY.�f,���v�UnEӻK������^���AB�H-T��3�vw��z�X*I|�V���z����2BA0���D ��6���P�Ġ�8Q/��!�+�H1#�$qRff�%�;c� �mI�����f��D�|fp3��A�����Zu�7�q	�?el@6	��Dh�!�5w�)>�Đ|��}1n��xf^���fIgw����[K�N>BX�����ee�S���a���fOw���Q�] �f��#�bE��n���#�J��j+��`,�w�RGx��6���.%�sHa�Φ�3����rhu��E�)�HCP��t��z-����F���ڐ"��T����!"�W֑J�%�,J ���LU
��v ��G�������)�`[*����)b�X��$7%��~��b b9�B��1X��zbA�d�%������������5��^�[6�Mub�6��d��F�"�Hh	H���\=��^�� �,�oa˟�������/��ȸ	\&gHơ|5��h�r��	�g��$#r*b��J;7�=��-��UG8b�ꅡ��q�V�	���gZ,N��I&ݱFV΍z�`L��S��IF�򝦖<�! �)0B��Rc�&޾`��������
�0�B |*o9�Pz� �h,�#n���X�gA��	W
�t35��+7���u[BJ�OA�gԭm�M�:w]L���%S�P+Yt��	��BF�c�sI](�@Yp5����]O�{A���j���e�9zG��H�[�0�L����G�����klt�Ġ��|��J�Yl4]8R����B����)0<�N�\-���ȼ�X�v���wb=� �7K��+�Is�04���(����s�W �:��{l�XQ�9�$�aU��R|�FxD�@�]�z��	�:��=eA���Vp-�69�S��\R��Y���BB)��#M�G$LC@�{!J)!��NF�l+�2B���H�m�B#)�,V�#��=�3[L�@�R��U��`�`e�2��wecYr# ��s�m��O��b��7Ƿnޢ�	�A�D�z���D�9��R2�<R)�oSTK�5`��TtÆ��*&TTL�o��BA�� !�rE8P���Ə