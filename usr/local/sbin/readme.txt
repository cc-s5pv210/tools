工具说明文件：
本工具包由广州天嵌计算机科技有限公司制作提供，以方便广大嵌入式用户制作各种文件系统。
下面是工具说明：
mkcramfs		制作cramfs镜像的工具
mkimage			制作jffs2镜像的工具

mkyaffs2image		制作2.6的yaffs2的镜像工具（针对Nand Flash是128MB到1GB的）

mkyaffsimage		制作2.6.13的yaffs2的镜像工具

mkyaffsimage_2		制作2.6.25.8或2.6.30.4或更高版本内核的yaffs2的镜像工具（针对Nand Flash是64MB的）

mkubifsimage		制作UBIFS文件系统镜像的工具（针对256MB到1GB的SLC的Nand Flash）
mkyaffs2image_for_TQ210 制作专门针对TQ210的Linux和Android使用的yaffs镜像
工具使用格式：
工具名 文件系统目录 镜像名

mkubifsimage 用法
mkubifsimage -r 文件系统目录 -o 镜像名

