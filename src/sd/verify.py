# 逻辑概述：以二进制只读模式打开指定的 .img 文件，读取最开头的 5 个字节，并以十六进制和整数形式打印输出。
def read_img_header(file_path):
    try:
        # 以二进制只读模式 ('rb') 打开文件
        with open(file_path, "rb") as f:
            # 读取前 5 个数据点（字节）
            data = f.read(5)
            
            if not data:
                print("文件为空！")
                return

            print(f"Ariel，这是文件 {file_path} 的前 5 个字节数据：")
            
            # 1. 以十六进制格式显示（常用于查看文件头/魔数）
            hex_data = data.hex(' ').upper()
            print(f"十六进制: {hex_data}")
            
            # 2. 以十进制整数列表显示（如果你更习惯看数字）
            int_data = list(data)
            print(f"十进制整数: {int_data}")
            
    except FileNotFoundError:
        print("错误：找不到该文件，请检查路径是否正确。")
    except Exception as e:
        print(f"发生错误: {e}")

# 调用示例：
read_img_header(r"D:\ece385\final\ece385-final\src\sd\sd_image_small.img")