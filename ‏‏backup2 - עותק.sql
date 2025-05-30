PGDMP      2                }        
   mydatabase    17.4 (Debian 17.4-1.pgdg120+2)    17.2 .    o           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            p           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            q           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            r           1262    16384 
   mydatabase    DATABASE     u   CREATE DATABASE mydatabase WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';
    DROP DATABASE mydatabase;
                     riki    false            �            1259    40961    containers_    TABLE     {   CREATE TABLE public.containers_ (
    containerid_ integer NOT NULL,
    type_ integer,
    capacityl_ double precision
);
    DROP TABLE public.containers_;
       public         heap r       riki    false            �            1259    40964    employee    TABLE     �   CREATE TABLE public.employee (
    employeeid integer NOT NULL,
    role character varying(6),
    name character varying(10) NOT NULL
);
    DROP TABLE public.employee;
       public         heap r       riki    false            �            1259    40967    finalproduct_    TABLE       CREATE TABLE public.finalproduct_ (
    quntityofbottle double precision,
    batchnumber_ integer NOT NULL,
    winetype_ character varying(30),
    bottlingdate_ date,
    numbottls integer NOT NULL,
    CONSTRAINT check_positive_bottles CHECK ((numbottls >= 0))
);
 !   DROP TABLE public.finalproduct_;
       public         heap r       riki    false            �            1259    41052    grape_varieties    TABLE     Y   CREATE TABLE public.grape_varieties (
    id integer NOT NULL,
    name text NOT NULL
);
 #   DROP TABLE public.grape_varieties;
       public         heap r       riki    false            �            1259    40970    grapes    TABLE     i   CREATE TABLE public.grapes (
    grapeid integer NOT NULL,
    variety integer,
    harvestdate_ date
);
    DROP TABLE public.grapes;
       public         heap r       riki    false            �            1259    40973 
   materials_    TABLE     �   CREATE TABLE public.materials_ (
    materialid_ integer NOT NULL,
    name_ character varying(10),
    supplierid_ integer,
    quantityavailable_ double precision
);
    DROP TABLE public.materials_;
       public         heap r       riki    false            �            1259    40976    process_equipment    TABLE     n   CREATE TABLE public.process_equipment (
    equipmentid_ integer NOT NULL,
    processid_ integer NOT NULL
);
 %   DROP TABLE public.process_equipment;
       public         heap r       riki    false            �            1259    40979    process_materials    TABLE     �   CREATE TABLE public.process_materials (
    usageamount integer,
    processid_ integer NOT NULL,
    materialid_ integer NOT NULL
);
 %   DROP TABLE public.process_materials;
       public         heap r       riki    false            �            1259    40982    processcontainers    TABLE     n   CREATE TABLE public.processcontainers (
    containerid_ integer NOT NULL,
    processid_ integer NOT NULL
);
 %   DROP TABLE public.processcontainers;
       public         heap r       riki    false            �            1259    40985    productionequipment_    TABLE     �   CREATE TABLE public.productionequipment_ (
    equipmentid_ integer NOT NULL,
    type_ character(10),
    status_ character varying(10)
);
 (   DROP TABLE public.productionequipment_;
       public         heap r       riki    false            �            1259    40988    productionprocess_    TABLE     �   CREATE TABLE public.productionprocess_ (
    processid_ integer NOT NULL,
    type_ integer,
    startdate_ date,
    enddate_ date,
    seqnumber integer,
    grapeid integer,
    employeeid integer,
    batchnumber_ integer
);
 &   DROP TABLE public.productionprocess_;
       public         heap r       riki    false            b          0    40961    containers_ 
   TABLE DATA           F   COPY public.containers_ (containerid_, type_, capacityl_) FROM stdin;
    public               riki    false    217   ^:       c          0    40964    employee 
   TABLE DATA           :   COPY public.employee (employeeid, role, name) FROM stdin;
    public               riki    false    218   
E       d          0    40967    finalproduct_ 
   TABLE DATA           k   COPY public.finalproduct_ (quntityofbottle, batchnumber_, winetype_, bottlingdate_, numbottls) FROM stdin;
    public               riki    false    219   >F       l          0    41052    grape_varieties 
   TABLE DATA           3   COPY public.grape_varieties (id, name) FROM stdin;
    public               riki    false    227   �Y       e          0    40970    grapes 
   TABLE DATA           @   COPY public.grapes (grapeid, variety, harvestdate_) FROM stdin;
    public               riki    false    220   �Z       f          0    40973 
   materials_ 
   TABLE DATA           Y   COPY public.materials_ (materialid_, name_, supplierid_, quantityavailable_) FROM stdin;
    public               riki    false    221   [       g          0    40976    process_equipment 
   TABLE DATA           E   COPY public.process_equipment (equipmentid_, processid_) FROM stdin;
    public               riki    false    222   �[       h          0    40979    process_materials 
   TABLE DATA           Q   COPY public.process_materials (usageamount, processid_, materialid_) FROM stdin;
    public               riki    false    223   �f       i          0    40982    processcontainers 
   TABLE DATA           E   COPY public.processcontainers (containerid_, processid_) FROM stdin;
    public               riki    false    224   
m       j          0    40985    productionequipment_ 
   TABLE DATA           L   COPY public.productionequipment_ (equipmentid_, type_, status_) FROM stdin;
    public               riki    false    225   dz       k          0    40988    productionprocess_ 
   TABLE DATA           �   COPY public.productionprocess_ (processid_, type_, startdate_, enddate_, seqnumber, grapeid, employeeid, batchnumber_) FROM stdin;
    public               riki    false    226   p{       �           2606    40992    containers_ containers__pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.containers_
    ADD CONSTRAINT containers__pkey PRIMARY KEY (containerid_);
 F   ALTER TABLE ONLY public.containers_ DROP CONSTRAINT containers__pkey;
       public                 riki    false    217            �           2606    40994    employee employee_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employeeid);
 @   ALTER TABLE ONLY public.employee DROP CONSTRAINT employee_pkey;
       public                 riki    false    218            �           2606    40996     finalproduct_ finalproduct__pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.finalproduct_
    ADD CONSTRAINT finalproduct__pkey PRIMARY KEY (batchnumber_);
 J   ALTER TABLE ONLY public.finalproduct_ DROP CONSTRAINT finalproduct__pkey;
       public                 riki    false    219            �           2606    41058 $   grape_varieties grape_varieties_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.grape_varieties
    ADD CONSTRAINT grape_varieties_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.grape_varieties DROP CONSTRAINT grape_varieties_pkey;
       public                 riki    false    227            �           2606    40998    grapes grapes_pkey 
   CONSTRAINT     U   ALTER TABLE ONLY public.grapes
    ADD CONSTRAINT grapes_pkey PRIMARY KEY (grapeid);
 <   ALTER TABLE ONLY public.grapes DROP CONSTRAINT grapes_pkey;
       public                 riki    false    220            �           2606    41000    materials_ materials__pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public.materials_
    ADD CONSTRAINT materials__pkey PRIMARY KEY (materialid_);
 D   ALTER TABLE ONLY public.materials_ DROP CONSTRAINT materials__pkey;
       public                 riki    false    221            �           2606    41002 (   process_equipment process_equipment_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.process_equipment
    ADD CONSTRAINT process_equipment_pkey PRIMARY KEY (equipmentid_, processid_);
 R   ALTER TABLE ONLY public.process_equipment DROP CONSTRAINT process_equipment_pkey;
       public                 riki    false    222    222            �           2606    41004 (   process_materials process_materials_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public.process_materials
    ADD CONSTRAINT process_materials_pkey PRIMARY KEY (processid_, materialid_);
 R   ALTER TABLE ONLY public.process_materials DROP CONSTRAINT process_materials_pkey;
       public                 riki    false    223    223            �           2606    41006 (   processcontainers processcontainers_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.processcontainers
    ADD CONSTRAINT processcontainers_pkey PRIMARY KEY (containerid_, processid_);
 R   ALTER TABLE ONLY public.processcontainers DROP CONSTRAINT processcontainers_pkey;
       public                 riki    false    224    224            �           2606    41008 .   productionequipment_ productionequipment__pkey 
   CONSTRAINT     v   ALTER TABLE ONLY public.productionequipment_
    ADD CONSTRAINT productionequipment__pkey PRIMARY KEY (equipmentid_);
 X   ALTER TABLE ONLY public.productionequipment_ DROP CONSTRAINT productionequipment__pkey;
       public                 riki    false    225            �           2606    41010 *   productionprocess_ productionprocess__pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__pkey PRIMARY KEY (processid_);
 T   ALTER TABLE ONLY public.productionprocess_ DROP CONSTRAINT productionprocess__pkey;
       public                 riki    false    226            �           2606    41060    productionprocess_ fk_employee    FK CONSTRAINT     �   ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT fk_employee FOREIGN KEY (employeeid) REFERENCES public.employee(employeeid);
 H   ALTER TABLE ONLY public.productionprocess_ DROP CONSTRAINT fk_employee;
       public               riki    false    3253    218    226            �           2606    41011 5   process_equipment process_equipment_equipmentid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.process_equipment
    ADD CONSTRAINT process_equipment_equipmentid__fkey FOREIGN KEY (equipmentid_) REFERENCES public.productionequipment_(equipmentid_);
 _   ALTER TABLE ONLY public.process_equipment DROP CONSTRAINT process_equipment_equipmentid__fkey;
       public               riki    false    225    3267    222            �           2606    41016 3   process_equipment process_equipment_processid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.process_equipment
    ADD CONSTRAINT process_equipment_processid__fkey FOREIGN KEY (processid_) REFERENCES public.productionprocess_(processid_);
 ]   ALTER TABLE ONLY public.process_equipment DROP CONSTRAINT process_equipment_processid__fkey;
       public               riki    false    3269    222    226            �           2606    41021 4   process_materials process_materials_materialid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.process_materials
    ADD CONSTRAINT process_materials_materialid__fkey FOREIGN KEY (materialid_) REFERENCES public.materials_(materialid_);
 ^   ALTER TABLE ONLY public.process_materials DROP CONSTRAINT process_materials_materialid__fkey;
       public               riki    false    3259    221    223            �           2606    41026 3   process_materials process_materials_processid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.process_materials
    ADD CONSTRAINT process_materials_processid__fkey FOREIGN KEY (processid_) REFERENCES public.productionprocess_(processid_);
 ]   ALTER TABLE ONLY public.process_materials DROP CONSTRAINT process_materials_processid__fkey;
       public               riki    false    3269    226    223            �           2606    41031 5   processcontainers processcontainers_containerid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.processcontainers
    ADD CONSTRAINT processcontainers_containerid__fkey FOREIGN KEY (containerid_) REFERENCES public.containers_(containerid_);
 _   ALTER TABLE ONLY public.processcontainers DROP CONSTRAINT processcontainers_containerid__fkey;
       public               riki    false    217    3251    224            �           2606    41036 3   processcontainers processcontainers_processid__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.processcontainers
    ADD CONSTRAINT processcontainers_processid__fkey FOREIGN KEY (processid_) REFERENCES public.productionprocess_(processid_);
 ]   ALTER TABLE ONLY public.processcontainers DROP CONSTRAINT processcontainers_processid__fkey;
       public               riki    false    3269    226    224            �           2606    41041 7   productionprocess_ productionprocess__batchnumber__fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__batchnumber__fkey FOREIGN KEY (batchnumber_) REFERENCES public.finalproduct_(batchnumber_);
 a   ALTER TABLE ONLY public.productionprocess_ DROP CONSTRAINT productionprocess__batchnumber__fkey;
       public               riki    false    226    3255    219            �           2606    41046 2   productionprocess_ productionprocess__grapeid_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productionprocess_
    ADD CONSTRAINT productionprocess__grapeid_fkey FOREIGN KEY (grapeid) REFERENCES public.grapes(grapeid);
 \   ALTER TABLE ONLY public.productionprocess_ DROP CONSTRAINT productionprocess__grapeid_fkey;
       public               riki    false    3257    220    226            b   �
  x�5�I�)D����Iil�R�_G���c* 4�_���#~������'G������Z�]ci߹5�/~'�8��[Y�1���_�s�W�1�_u�����k�1�6��h�bk�1�د��y�G��j�N)���W=G�_�Z�#D��G$��Q�j�~���#�N��->w��ѩ����)�~��ȉ��g$f(�����[��8���J��n��ʑ�bJ�D�+���9c�Hݼ����Jh���8���ӣ���Q�Bm��Nu�b�Q2�om���ѓ+�9:�0ŧ�>��[ޓ�Gc�}��v����o4J��/טc}|��G�@��b�,�r��%;����g-���g���_0vĠs�6F�m3����ƪ5v���c��/v{s���[2��Z���-~�bItp��1�������#+r�O6T0�Ct��q�������*��s�R��Ë=Jf��]��=�|x�G��q'H���Kߍ��=�>�^�����{~2���zh��M�x�|9��*�Y[�� �wq�����%�Ml'�%
��0�i�� 9~#$e�9�O�)\*Zl �˦���6�|��߰�>)#p�
�ra�isX M�ˌ6�8��)?��V�H��X���M
.����&����$�b�����a��2V��8z}pQ��'� �.r�S��`
�Y9E�2f�@+�Ⱦ���k��.~��d�)��1QS���߸����W�l���٤�D�.���/_����Y�8Y"^oJ��|<���#�_��. �R\j�9S�S��(A�0��\�)�}.�Ͱ�X}#c��e寭�-,��dl�f�x{�|�m'bao㉵���XGZ{[GvB���ُ���Ci�(�M�����s�c:�)��K=R�:i��%���Z���y}D\LEř��O�#(�=.^2�ui�OEd��BWY8P�j)��s�V�������,Y�m�R���(����xW\� ^N#ĕ�T�&��n"c-��-ه��G1q�VąN���:KF`�.(�\�7\dK� �JN
��8;����'8���㊿ �֑�p���iDh[��tI�A�$tsB5��BY�Z� [���������dz�"�S����ĥR�#�R���'}����zQD����n�/���N�����\YJ��1E�YQƈ^f�_PI,�8H�G��זoA��5��d�e�k�J{HgW�̳Fa:�l�E���&x��mn8<��~����A�U���ZAg�HT�ݶ�'��&no�t�d��YС\*�l��;$���y=:�s�Y�.��5���Q�q_�{�r�6�UQDa,���S��J �5<Ty�Z�*Cܴ�l��z问z!uhP�|U���Z(ui�p�|;�.?�q�ʤ�;��4)�?�)~m�pt�j5?�j���:�L�Տ��^'..����Q�I�J�t�N��*.Éjg((D�4����|��a�4&�*^*ĪE�PRMc��Sf{xf��jz�X�!#b�4ȁ{>/�$R��f�(�t>���t{��I)��L���>�$��Y��Dh�?%1u�{d���{؍�^��׌��}�	Io_duʣ��'(N��p�D%7�r�(c\p���:�i��-w�P@|��ry�&��hg�gE���UO���jIաp�`����+�Y�@�š�=m���\ly2a�Y\�|�@ s����$�q��S��΄(�in���Q�g�)54N�P�;���u����\���P���(B�!s�X��]P c�V�Y��ӊ49v�uܱ�eJ�� (��+��"~4��+�,�mƒ4�[�I�:�!]Ï�y����$%ەK�2����[����@k2��Y\�Q�\��v}d���8A�m��"��c��I��g��4����8)��65���d������rİ@�pYR�	� DQ^A�D�Q%��*�H��[P��7�b)��2��=����t���-EC�Z�$$��U�T2�)l+� 𱴌}(d�H��\�A8_:W�P墡���ECr�"r�5Ô�-j�[�2j`��V���:�O�U��h\��تJ�"�F�EjJ�t|������={��
�r��DU�wr��5�]jMKc�G�y�I�t���m/W2��j9�R�.�;Hq��2�2�kIm�G�͘��N�Y(2I'o.^�\���Qr+���%�pO��u�*�'Ǔf��=1�Q��y�:�FW�P��U5�s3����ɪ����RO�6����<��y�}�8�Y�H�x�������F�".�8�]��N�����ʙ��%��P/S�y�k�ժ�G���D�S���:e*���c��LPHX��ӍtnC]��=���?<���ϋμn��h#���j!p�q�<�t�;�	�o�A�%#��~�'�f��j�����Ŀ�<���ɽ�Je'��_�>U�<����<�˦��6��a�5
R�������i�ETi��cv��u��M�R��,�F�R_���~q��E�F����9� `������[@��WcC��B�5�1ՙ����onז�Z~Qk����By��V���,�C����y\��XnUۥ�>���u���Y�B�o���RiR��C�6�!��I ��o4ٸ�1�Q~��K9}��$�s6�UC�O��s��ݪ��ò���A~P�k�hO�k��Ɓ��uD��r��t��1�'�|����F��ZQ~Q��䃽.��3��(d�`      c   $  x�EQ�N�0=�|��lG�B*�P.���E#������o�����Ն�~��Q&��#t����/:6CdOm��I'�s�Χ�Na.��e�.i��Z�[����-�l�4BØ��B�E&a�h�;�%6#���.͹ο��v���Z�M�8�0��v!�5)YZ�<�e�]BB��4��R��4Iޖ�"��֮�
N�i�:dUg���%�i���ODp�4�E����͕@�
¢Wk�X�(�٢x�y�no�{"��w�������P�>�����Z0<V���'~`��/�b      d      x�u\ˮ]9nE~�6D��cȨ� �f�nI�6�Ԥ�>|�ܻI5P(֑�D�H��/x���}��Wo�> >��[���9��>�h�o��׿~����9m4~M�/z��ǯ��#��k2�j�����������.�h,�������?���~���=��Wæ��Th>�}�� �5�!h����a��'�N����<۪�t��],�E�uh��������?���z�VqN��|l���o}=�����O���������_?w*s��옾)���I��׫�1	�eE�O��=��>q������o���p�r�;���Y�k�ز���eVU��U���]� �|ј�Y�X�����b����u*=�(� �k��*;싸|l<ք���6Q�8���/�v:�WWpu��w��2�n"���*��:ȘN%H����1��x9��fW�ç�혀��8�Ta6?(e�UA9�+%#T��O�����Bi�O�RP!�'i:Ȑ�'�W��/r�6:tj�*�i����5�����^_YW��2��v�K8�b�SU	���
�w�ER+V_�EQD����@����hɏ����~� � 7W�e�s"u ��+nl�ᣃ��l"��:�w}t�p�䝻�=�����X���%9�:U�/���x����U�~��ū[�@���fOJ�t���<��b�+��Z��!������D%�9F�- ���1gu{�$~Ň��Q+�gݝ]�ʣw]�,}�)w����x0���[z �q�g=Ә�;D�E �/�اC�1/>��Ǖ�5klR�q�o�b�r�q$R8��,q�kq��r3��u{�wOM�����N�:k����I�;���ѫJ�����\ΈZ;{k��jy��u]9fwk���]���s���\�V���Ƹ$�uD)�g?��܎8#8
�	�@�[��j�SG�gvr,�Ǩ-�-�{�=u
��;M�/ý� ���.��W��e���%��}�s��#۸Z19ƃ����-A��r�FK|F�.�Y�%
n���&`��-�RvW��lE�ӣ;HP����&c�\,+�#��3�&��;���G̵����D�n�++���������o�i�,�X�FTjL3��Y2[�"��i��q�x��t�6<�:m˵��z8&4�������C�ط�Do�9KSΡ\;�l��D��pIM���gh�����̦E�~���]4��8,PXLTl!&�!�%���g�^Yb�Y���m�rx@ny�px��9*z1s���S�/��K$Qt2�C1%7 W�4c�s@U>Ⱦ��oW����W�+� #�����=�wNeD?G\��^,+��� �������9�_[By2)s�� �{R7�q�#�`)9�ID0oJ��P����r� Fjce��$S
��������@h��N�(�3
[7I:f�;�	k�Jx}l����'/ ��9MTW��<�W� ���rM�?GW�:ŷKv�Ug�D�u	�M�(�p1��(�r�w�5�E�U��mJ�(_�2�x�U3���id����sX�E��vu/�&w�6�N�G<����5��U�~���ױs8��p=��)s�Pù��9*����=��Ե������`�`g�xj&��`����Q��=Q\����hK��yy@�X +��#?�*�4?�z�{$=�uF*��N �>+�+��m���%��`���r�s�r���#���	4�Yĉ1�����qit�j�5F�v����ҥ�m�ט%�fB��Uw�����N���{q���\�w,�����
�Q��8Y,�:�d�	�C�4���!���N����9�����BO��'S��=Qu͌�����9�4��;�Bܪ��.)+��&;G���I�5|z�<〈�]Q�f���(g��4�	:1����EA���"��:� �G��W�B~)�J�{|)N�]�9� ���'��#�x�i��s&��*/��b�W�����~37���kҨ'8����%� C�[qW�$;���G��[}�]��R�OF���|w�*b�cs�CI�ۮ�M��ۚ�h��1b~��.ٰw��\+8Ny�Y��^G\��}	ʒ��DE����̥��&F�9r�W$�YfN�������D���KX�$���\��f���{�Ho�X岭��G��V#��W�e"�}����.��ȴp���*�#6dy��^�1a �s�1~y�s�}	9r�ovL�0��v���n�~&(fT�f��VM����R�5�މ���A+���$�N�Z>-{B�~[OgQR�S��n�[�&6�쀒&Vt�V�g�(���R7%��g�rf��*P�p%)>�bdۉ�Q�l�ӖY@�Djߛ5*Kh�Jo9���� �*���i��2%�L��n��r4�6�Tڌ|�pQVIZ]����YNxx������\XMw���bBX�:�g}�tC��-K��(����g>0�g|rm�/|>��.'�7?��w�����al�#��%{fP$#3�����H+���X��%L�:/�nWh��x���Tx�ޫ��ٻ}#+�(5���E$���)w��I��e�Z�8�~��&M�e:F��'�@kv�ذ�~�J��+D���C	�M��ULZp<�M+��mD���m]}�'��Y*�Wu>>�!qU�Og��y�Z~E���C���\�Ƚqt�3�7�FBB̯|�`�q�,rɡ��1��-x�k�r���'[Ǒ�'�t��R����<�p�$4�;n\!<����p��/���4'�ί��GV_OÆJmE�����86��J`����y����s�tF�=�+��i��Y|d�WbϢ�oa�K�����g�������o�Hx)�G>�w��
ڥhd���$�1>3���gK�%_���o�h�.�
���������鍺wt��~�]*ɖJ�H�p������W+מ9x��B
��OR˥���uH�P[^�ާ��a�[5 ��(������	�.����N��1��%�[+&*erW��-mg���Cv��ֲ����B���=�Kb�L4���Q���f-�"�t(�Q��9�-QR�n���A|�N�Ö��eh��H�b��~����*
����e��/�*����ł����(�Mo���˹�e�h�znV�6�9c�����Z"�g����3Y��[��v0��g�c%(m_�c_�=�fCt�f� ���J����������l2��G�����U�h��T��Y�@������.5��u:A�����3ZZZ����ѭk�[$h�R�
-�����[�Q\���X3/n�w�]�89��3;Ws�;�c��J�Z'�w�V�ԁ���'k�=M�|��F�6�
絬�kBa�Eee<�ُ4+���gA0ژ��K�Ø���pubQ+!�\i<��p���z@*@Idԉ���S�$��=��k�����N���.�EϬS�R�ӻ��w���zk�9���ԫ����YǦ�q��еU�	��--a�୮�_=�(4��8C�+���`�ʇ-����plqsd�L��Џ��/s�h�@2K���2�:w*Eh�pƁW)�Z(F�I�d�2A3�*�2F�ƮW��xI�V�ε�#�ehqFoh-�"�u{�1����"}��J��"����8�k�J&&��<�o(pR��=��T�f��m7f1����.S�~Z�I�i�T�*�=�4h����[7v�'����~�l��f��q_�:����ѪW�x��A��0�:F/�k�հ�����m����.��%���v�Fۻ#�3�L����+!+9��S���?��ul�qJ�?z��b�4�z=�`3�Ks�%T=�/��S.��O =e<�Qr����2ܞ,�k:?����6�r��!����n_�KYӄ���RѵZ['{RZe�]{;�\�$�m�El�*m'�qj&Pޣ�GGG��������u�+6vi;��;;�}��m��b\&��{ZM�4�3f��-�.M���Z��g>�/�l�Վ�UZ�uF���4���ۥ�-I� nu�J�-r� �  WQ�H�g�R�x=EY��5���3=��ZO�6�[�V�@!boW܆Q�g�Zʠ��^�W���Ω��K�c��(c2-���5]�6�q�Uj�=�
#�ik�W��V-����i�|{?ğ.��&�C�`���Yf|^M򅹶2�1	��,O��|!*�'���(�ͬ*�G-Fˌ����Jnw��b��S��Ɛ3Xb��:���W?�y�B��Q�<������(���!�F��T��X�#�Y�8ڧ=�+]���N�E��gX��p���7��b��(g�ݣ��"8!�O2�U�C���5���dʆK�9���%?p����]�V5(^^-�&k!��*6Q�[-3�U���uzt&w�z�����5�n�

�^^��	 ��9}�{ަ^Hwm>#_�m'��"�f��υ�u^�5H/�������hA�C�ƴ-�X�����;;6�j��χl���	8S��}O6����!᨟�.���#��.����M�Dٳ*�J­`9��%���H��i��z&�S-�_P��,��%�ϼ�\>��ߎ&�V奔��,�/Z�e�d}�lCTR�i~7��ͱ�of	��+-�P<�v6��U�V�^��N�h��'��I�._�>�O�|f\{4�ѳ]R/`�.}�ʶ�TMy�e��q�8������L.��7�D�B.�'��5�Yۖ���FL���hJE���t��f]Ϲ�{4M��/�l�4B��n���78Z��ș=�����w�[Gg%�Qt>^?�n,�{�%�e�rHS���[�S�F��C���;:]G塦vD�ة;��R*D�&i��;.�A����K����S��:>��XNL���
�_9�x��V����F�*�@��+|k�%�tZOq��#��E'�l�
O��.�� ͠�[�Jk�����P��������ӷo���G�      l   �   x��K
�0 ���)z���٪�"v'n�u��8���^��Y��4$�50����8O2��._�bo���$���}�s�ҺSI)� �$�tA
����YZ+�!�����n��7-Z}��I�w�x� �ч)�      e   q   x�M��C1�l/D�`���:"+~Q����KD�и�B��Ln��F��oƕ����K�,,�ȹ-�J�^_bKñe:�O�e�20��ώ�5�du�����_�X���(�"�      f   �   x�E�An�0E�ps��$O՚HIT��/��l������97Dg�,��+l����R7����xE���c&j^S�ڀ)�2*ls,�q&�5��0�F��������cQ3W��F��\�wbI���HE��8���+�ݺ(4��;,���h��!�Z�0��{���Bl�Ms#|��k\9�SRs��E ��@�      g   �
  x�=�ە�6C�=��z���_G�o~vvƲD� �������������k�i����G�o�ﯵg�_��x_֮�O��WZv���k��z�v����C��eӓ��������~�٥E������kC+�̚�jڱ�Ͷ�Q��M'������N�O��[�9��.nҴR��������{t�~����qmi��'��G����w��*穲[|��>m�o��׵�w|�&O^�V��o���}j��e�v�uK�M?i2D.�YUG�ʂ�l��3�l��D�/��]^ ';H��{mLul��V����!��m^��wi�M��
`H��޽u�Q���y���ֶ�d"�͵ʧ�Dņh_K��z�O_N�����;:�2o����$�X��[B�Cm�����
{@א��a{��SwL�iG��w�[���Ů:�^�X�P�������SnD	s�)�wy��dJ��
�꾱� k�6�J��~�>�� ���Y�W�h�q�O��i_,����'N�֔�v_�zӦ�����a#OK�CN��H6?�7=<m�Y^QR蜵�6��K��xa��,�m�ID�Sl7!*֌��Ղ0��ghg�y��S^�:�Z��+L8��1������v`�jNmG`�+����#�M��+�����e����}��J?���c�p�_���T@��/�6L�,;ޢ�6	���$��[���=���*����2���K��I$���oB\�=8@;N���q�0"m]0��F�o���	)���,s5p6X�︌,�&\�� �M4�Y��/�*"t���<ׂD.�*'�&e'�h�b' B\#s����:s~��+�%1s*%�����1�|O�ˊ�6@��{��i���P����6�>�$9S^jʲJ~��_��qc�6#���4�9�߄�����:\'�r�rQk���[˖� ���P%�Kq���kț[''��%�cb�>���p�i��c��F�� 
!Լ��\#���Wsc�k�ݩ�С������U���Np�Tj�o��%fmy���.{��Rv\�X7�c���M;��/g2�ZЪ������Lu�*�H��n3��$5d��i�t�خ�q$��ō��A�S�:�`����t�  �en��7H<������L+�(��9J�KP�cw�?��
�øyT�:�m��(�Z�9� wuF�o�)Y�Z�R�g�&�b}G��7hͲ�A�w#�L��90��C)<nY��M�S�"�%k��A�8c1��J�A����cؤ��7�,L�,�~��A��rST�E�iQ�
������H�Q_j5��@�.#W�<&W��e����w���J[xs��"�6�2/���[���P5�����[�aDW9rNtc�B��P�Wr�D�^j�b�[�/���±R'q�
U�ِI�h�}�����-� z٪�tSQ�.3ڬ`~��O�Ü:Il�����]|�n��[�6&LRLd���|�]D��'�u.E=�����_�=5�"]�W(+]�p ]��q�!\�(�⥾�W�g�h{�[����x�L�_����?pm��ܻ>f��ĸ�h�zm#��f�G���Z�!Ê�%�)5fh��uu�u�R�%�+l�т�ko^�ݛ5H��#B6r�"H��GGxA�`�O3�`�i��B��|xItㅠ���v���փ��C���$�H{b�MI�;}̱�o���(T/�0Gx�24�����s3G�!i���k��P�'�u�p	�z��£ ��˰ ��ݗ���/Z�>wW���G���ݤ~'��8�M[��`�H���m��qo^�{R/��+�S=�_9+��0!Y��� �+Tz<��#._;4�*:oC�@�X�J{��wXI�����pa$wRt��.0BV��}n�vO���N�=aTp��7
M噄9�MHքH>+�\�ݽٿ.�����AΓd�U�kI��6+h:�o�r����p����h��[��擒�0^�7rux`����G4�����i��S2�n�}+Eu ���i�P�=��䡛m$������KK}���v=�k���T;K�7^ǿ���u:ޭ��\&��D�.�\�kwv*�A�i7Ie�Bm�%"P��L-��x��oT_0�o*�e)���;r���
>o�[���� f4h�1�7���Ia���y�T��[���ڣߝH�+���8��ۑ��������u�l���U�����>�fTw{�� ϼ$��13xQ��g��8Hoıq����j�6M�V�Uǌ�|�7��D���º27�.[F���ݙa�7=CϢ�a�w��eJT�%��;Ҽü�E���O���s�q�D37�Û��@���p�+=#�C�*��&��FE�BT1?z�|�?QB�O���o����h��SnE�}C���I�?�/�+S��\*�sK�6��3j�r �V�RliM?�H����q�Ws�Ep�0zh�����Jg�85:���2�y�Ƞ�'�a���Of3�G:����;�܃�-�p���8��xbE�6h�ޘ��p�+v�EC ���N~%��oD���0B�|��fd_�����9+��I� ~>�j����V�XP�pG�_*��b,�6�4p�f�� v��2P��#4�¦-C6�E��5���~�NԬ�L�OoH� ߑ�B�>oZ�sQ#�fX>�'Ꮘ�t}�ʛzp�4QT�զ
U�·�ω-']n��ԕ��ezy-s���HZ��4*��߿��~�� ��_      h   (  x�=�K�%9C����1��^z��h]�e��eD؀������l{~��w[�/v|������^��E�f�����Q:z�"�8G�b|5R���Ř�����u��M}rt�.NM���ۼ*ݘ��d\��W�K����E)�F���~��;M'C7�B��u�����ѣ��'��=��P����������+����.j�~�8�G�����)���<:GY9��+}���&���y��r��%�&`c�y�+!�S�GQ��m�+��)jQ|�*)Z�	$*�Vwm�Y�uJ���i���d�<�Z�U��9��u�:�U�BR��7�5n��j�U�|]�7
����  `�~����H��zbj�gM��t��`(������K��-Z���M���ɧ!F�j�>K�j ��NMݾ
��J+`�߁�s?�M��;�
&�:��".
0�PVG1J�]��r4QH�D�K}	��q"��`�Z�<�4Q0��jPmp�5"��/*���w�HM�� �ЩM��K���VY�Í�ۍT�I��o�n�G�QO�)�Nۢ-�'����f�R�fm�@?�
W�!�h�M�X�?��%H<�d��J�Ia�f���T���ubS�	%ʱ�-����2�xݢ:�Y_���7^�x����-X�Y>IŅ�-�I`fԂ�YH�ڋDԕLBg��a����i�x�9�䘵?WTL�^�s�I���H��n�0��M]�;�KK�;,Xf���A-����<��xDzY�
��S�^C���S-�Vώ�� �t��9��҄���%��|'��E�D3�����i�������q��Mʌ& ?l�!�]�.��qb�z�nU��=��4�1��P��Q}�)����|��`$Am����a�e7��?�e���ۘ���qaei�#%�ę��`OF�u�p����p��Y.�TE-j^�E��brOQ�/ikأ��i�;Ó���pہ���cZ��i+��BI
�~j����J���d��( -���R�Y���uk|ݴ�6�}�Bwԃ���[�\0Cė$��}�J�����>�D͉� ?���
����h��Ͼp���!ɷ�[�_�)O&�m?��aQ :�J��H��]���0ͧ���{��d��٢=p���K���gzNy.��k��x8�u���򌿶��Jm������WB�Y� �YhT��U?�b����0*-(�5��ÇEy�я,]�*1׶ls�n�b��#�f%c"/09~�
��K� m�L��!���׵�H�x��]%������v1����mF�^֧��5���Zy]N��` 6�ʉ���k�6�eu^$��ámY��Dۨ�^B����,�B�̓Kz�����8s�h�9Y����ôc�͟qf%/�+�[�̠m>cֈ�u��?0�����v��K3w�xСӒQ3�)0=ɰ�0�^,�����j��v�G�{^�/��X� V���b�9f���>>�=_Q�2�/�1�^Z�����)	f�g0�&v��M�L�)@��׬�VU�����!���6~=@�%i�����XR��۟����[V��i��YL�      i   J  x�=�[�$9C�Ë�c�{/��u��Ț���c����_�j��=[����|�����{����m��e�m�������W�|�s�q�y������ze�9���nꝣ���Ȗs��>�b�]_�]'��Z���d{��[.��:�/��6C')�>�ﻷ����S���C��o�lk�H2��o
6��+O*��E���P4��n�z$��Ѕ����z4��0tQ.������מ~�:o����C_�r(�����oߧ�����n{J���]oX˙}7�����[J���lT����k�>��:a]�����7�7�2�-u�CnOS4z���8+�7۽�Qe{�����r�B{�}�P�S/�#LE���[��_���U�ws?�5�XާrGꜱ\�����+AR&�q;�TwZ��{��ۺ���*S^e%�j�H�uzd ]���~v�Է����dN �c�����o�+��[u�nG_��rH��~T�6X�<�Va��twR)�do;
�:����l���(�=\�*$d�j\��N��ӪD��" �f<$=����(­��T�g��/�xJ�>��:�M��dG7�Su��.B��hT5��-���*�S���R���	�SG�&ʖRv�� B��
:��

�s)i�+(j�s�V:��Cb)��߇�A�J� Z�T+���>��(ȇ�%���U�k QϦ~^E�)�>���
���W&�TX��J}�Y��q��q��J�S�X�����=u�R��njF�{OO��LA�s	�G�8��ޔ���*I�0L㐨��v����a�_�x"8&t7�?�^`e5�殹E(�S���"<M}�ʉ3rwgYW�n�)#I�&��P�x�m�/�w�ք�te5�$�uN 3���(�Zum�wmG�o��覿<CE�JA6`}�?
��4�-�D��gش��R��"%һ:F�r0����p��=�y�Ee�ahV!s� ���3b�Y���4BM�SlAmq]ZtX�C�EkB�` ����G��F;�:BK�(�ro���"��l�0'*���녪�$
��
������  ��U��|^%$�0�+Tw��"�L�j_���H���q�b��q��SA�b�|.aYTV���4sJ>�A˕���T*�V�w/Bz���S���ן�g�Y�CP�s��#�I�0 �]~e�W@���C�(���^��u��{� �%�:�O�K$EJ�rG��hL��z����L\�{S!�q�<J֕D?����z0��Fu�A�D�pP�n:�9)�x�os
��4�8�#.��2$��i85���-��v1~v�$N�]�2������Q\�"�K,���%�a���/3{"�Q�
VpT���>5--��&��PG(h=Y\��cDI9����n�����%u��5��)�U��E�g����@��=EYi(���Av��y�в����6�h�\tx,E�)mV��<P@^G���ՅCƃQ�[��i	�)D�\/Ua�X��n�=��1�eNQ�����Y���,/���BŮ�cڪ��,�ɚ����9"Ƿ#Luҋ�[;����e:�G"o���˥WC���U�Kp�A�18M��ƴ��J;Ï �{t0BX�܃ $��ڒF��s��@>��
�鷔'�D�� 8��*f],�ʹC����g#2
����H\vE_��`A����$	�n��b����_�|����mI�-v��`m�<P	:d���r�ݷ��������>��a�B��j�uN�z�cqY�����!:�\�� �\��B!��z�0��T:F5ff�5�y�:�������|�II<����<)8Cp�'�?�I�C����\�����������˓�>����b�`=OR��0���,3���U�F���� .2̍��1@�z��@Ffp�t�)�4-���+��c�tx�'Pa����薫��>��Zd�`�|���C�Re���bP5��9�O����qb�zy���U�P~o�-��=��__�ګ�L|�#2m��a�F������`����0�c|u4��v��=3�2���(�|�ׂl{
k3�ur^�����2��F�5+J``����J�fc��rےz�ZǙ5�S*/^�0+&H�&��-̘U���#ʎ, ���F԰����� y�~�����J�<��!������B2^��y��Fu�ȉ��5����������}�hO����AAM��G8q� }���:UY+_�Y»�jQe�F��;dH�������>�6�U�Gkb��M��t�
�bO����
[�Ț�5������e��*�Ul^m�Yc�l&�����Uf��̪M[,[�]�Ax�@�OY�W�6��N�z
= 780!f�BB&�6GS+�1�|�e)⧨�^Q[1�to?Xb��oxɨY!��ۙ��;|%/2�܄�FuG�!T����	�-�d��X�-�5X���gc�_���=Ђn{��<�gZv�:����[R0��,тiF<�w�P�_d��iY�|�{�T.u�<O_3>�����/��%}�����J���L�6)�^(��om��L^c�i������B����fh�Ɂz�DCRV&bN����)�*~�����ݴfh$k��h�Tψ̸ݪ@�ӫ��u�1A%��mf�X̄]d��g���&�U�	�ͣ�k�!S2�M��M��Q�fOtX-� ~�w���b28��&���Xzk��j����4�	c���S3�~^(���4�q��Ql�5�b�c��������� ��4a��H�eYA��(h�3�[t&m�M�˶9�� c8Ua�[�p+3�z{;<�=�?�ۡ2=��5�GQ����y�-Y~�hazf����O�"�Ӈ�*��5/�zO���|�㕮)�

��,�����d�y����o4p&�M��Y|❏��$��a�J
��g z����L�^8�,0�u�d9�ңW+A����;	��}=���j^����y x�ߖ�sz��>L�^�û8'�0�m��`E�sz�|$��=�J�p/�X�xEc��<���e������}�<%��噭w�U!�]�S��m-8̾}D���Da�y1�x�g;�4�e%���572�?���`�,�?�(�;�W����c�V�O�#����o-�\&K%��e�m`س���n���ٛ���(�a���k�j�&�Ռk�`w nQ2v�뀣�<ɧT��*�M�����k��eǪ����GG7:Hw���˱}���7��.�33I������� �ӷk	/�Yix2�����	̆lF�Ep��n��Zk�@�|      j   �   x�mRM��0<o~E~�tw�yU����KЀEm%V���I���0;3�	�nh��Nk��L����h�6��j���U?�;���iU��{�W�"b	K3�\��*��5l��l�n`��S3؛����E�z��F�cS'�"a�11�Xsv���m��=JYڲ_� DB~G�\�Xz�B�T�M�Z����3i|F����X���V�]m��k*����,�����Λ����3���PJ����N      k   �  x�}�Y�ܸD�K{�q����u4�����U�n[Q�\�f��'��3�9��8���I���8ʧ|�6��}�� T?u�d��O�<}jԜ����}>>�^7��iN���G���0�hNy����I'��S�s��X0�2M����f��>�֗|�셋J<��3,�5��^��*_<�j��U��Jʞ♱W����#��kr��>��S���%�:�`���A��E�:�~,�V6t�÷c��ڏ3���N+�O�\�쌂 }���߮��>�|�>uL�� �q�����#>7�� mi���p�U@�$+O�Ag�ԗ�Y�d?����ܧt���Oò~VR�D4����T]� �S�l���r����P�1)����/�j�BF�ʏ�3��y����.�ϙ���B���?N��*�hN�~���za�g?ʠI�[�a.�k�C�f�2�����G=?����i�`U$�܏�ܩT�Qo��È�I�Y�ce?��J�}��c^.ZNmq�?}?^�cw �<���S�>������-�S���0?rǶ�W���v}5i��ا�B�l�<�I;����8�h^�Ӯ~��L�I%Zl	y��:U��dr�cy�s�h,��>*h�4)�����U�tK}"��ݺ`F��hb��	��ϣ6��nG]���tD�$��O6{$�q0(�^�S-�����3�I7��b����B�<mh:o��~8hGm������q�K�cl��G���k���G��j��ӎ3C��q�/��\���bO���_������!6�9������X�)4�)"�r���ѩᡯ�:�!ۣ	M]Cq4�(���|��Z=.�f�v�.���3(g�+ܷ�o��hF=0�T�a�fY�1����UW{P��6��Y���/V�żFP��#ʲ��|g�%�3CY��X)�wwvNqϞ3�mZԯ��#�r�c�E5�C75�^���hө�����!�׽&��6�1+��׹Bj�!�?5���Ù�3 ����t�e&�!�j8.���z���|R��Ⰶ�xWi���aMك-�G��[y���e�X�b3N>WJ2V���" �X�P9�!�T��̫��y��xz�f^�w^QFpb�ł�[�����s�����#���56xk��i$�J��8a�L�K?�����{LpBע������mBN����2G��#�������!1���0-��S� Y�Ӳ�%
���C���d�*!#⮠(���1r<@ԋ�Fbf�%A}ߏ36�Z�D��uKD�IX�G��#�~i��/B.	=�^��?|��\>����H8��Ƌ7���=ږ������[@��>ѸWDqd��P���$(��3=v��M����r�K�H^�y�1�<�(��͹}.��B�L�7R��9�/�>0��F2d�6|���9��Xxk�]�VYxsSHZ[X�}��w�*@�xƖ@�m�❢�a���y��g��h[�Q<"�{4��=�9�;�˪�1��i�BB����v��x�c�)��MN�
#��_	�u?͑�f�������"0k�����Vԛ�pc/PH�"����^��1��z]��q���@�#�Ǝ ��P��&��z�س+V�v\o	��΅I�G
.�;��:�9R���V�K)�Օfl��Խ强Ў���?�rĎ��u���j9��ƒX�lш-s#cPR^�E�|��$ڣ��|@I$D�N��+0�y�M�PP$l������nL�^R�pnꀱhP�\y��Ov.32���m=.����I�� `��x8��� >��:M��!��#�@��>���vy��3������5�m{G~ٷ��+?����X��o�T`R���3��apdĪ���n?�I�St��F�1)y�6�6_*0���{m�_,����G�ea�Z9,��'��Q7��>�2�VE�\���ԡ�q���B�|��q��i�	;R�J��̻��A��(����*��5����O��fzl���$G��G�9�i�$�d��(u�I��x5!�AI�,V����i��m	8�d��}����!u�(��qyH+�Z��q}��z��Q��@�dN�Gt�¸B�l�FLJD�njT=���mG��8V_�특ͅ�ۖ���lۄ&�"y?\�[�b�HԶ�;I�(�ܚ[.`Y�=��^�bE�����L��' ����j��H�JzҊY
Jz��Fb�|��Q�%�m\�W�L��Ҋ)��@q|���ڹ0��n�q��)�vQ`]��x�W$&A�?�zE��Y`�/�v�J��2q�|��V��!0ɗ��=0ɗ��h� {��Po���|�aDW3�v�!�a�T8U�w@#�(�/S��:& ~%G�'0Q���Q""%* 	T`,L��O��'�e��	�M���0�<��e�&��Gs�����>R�(��)�I�����y���m����ׁI���|_ʮ��w��J��(��t4E��1��t��	;'�@*����E�l��Ɂ�qn���VKq��sE i����'�u�j���+�Ѻd	�牤��o�9�W�"]�d�,Lr���<��9Bڣ�{uTS��t��K%��h���N/�� L�e�o��4&-�GK�������iՌ.TX�6�՘�1�1q�K�PׅI�XB��� �lY�
�`?v�-kf���$[��rWU��$[�Fn�@=0i�KW��"aäcLK�ۂa��1=F��-�c�4ޣ�PRXǤ~*{����CN͖/��[��0��f��U`�-��r��0q
䈰o(w$7?��<�x��W4�%A�d]l���={h��~f��TN�~�p^�sJZr����)����ޯ/%ͳGӥ!�)6}ʐ�祥��cra�Q҅D���飢{�����vF��>z13���6_��bK���v����0.�����`���B�q��F�'�"��M�mT�RJ�M<Z��Z�B�B��t�@5��A`�=�UAM=(�H��F00� S8�`4�G;G��D:pQ5(�K�SV��)	����hm�7���/O+G�F��,/�9΁���eT���q����'�X��*FD��m�4Jn��e�e:P\�ZS	G�T�;rRT�Q��d����24l[��������¸����P	�3N������o��<���q���� {s =l�\�/0?cQ\�������(����P�(}��m!K�2k��
Pz9IB,�u��B���]{�o�]����QGp�O.=*	�K �e!���#�v�6V[�z�!}ar���q����1m!�5^���8��T�����챴��>n���X�=�Eq�T��ƕ����,E�9�yY����"Ԭ%d�H��ma���Q#e�}�V>Q���n�O�b.|F#�Ko��>���4�"��;0t�imڢ$�+*�{=�\����c^W���$
��͊���$�&s]F��A���;%��(���,\�H��&��lXK�q5Pz����O��dX�:+��ʋ�E�������G��źlT3J.=b�	&�2霕�c��E�=�}��~�l����!�-n� 5��\x��z˄��rP�(��K|��;�1.�f��<@X�����nx��8�8�
��7&}��G�B�.��m���Ѓ$Mc��ǌ���=�=ԝ��Ia�V	3��YcJ���|#�r,L
�RJE�q-�]�~�`y���GF�=2�E7�r�Z��]�\����KL��XN1�h��{k��hk��Q~6�[T�{k�o��W��{��p�d�y&�?e��8N���> m�cG�=���0v|%f O���~�?�����u���b7(n���NPr��u�g�_�1J�Ē��hi��q�y��m]��>��^Pq����.mKQ��:�´�d���
�T��D[��8y�mϱэ�1�s{�m���p{�m/�}o�~�=�������������� �     