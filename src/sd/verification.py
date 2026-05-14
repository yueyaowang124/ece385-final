# 逻辑概述：从 SD 卡指定位置开始读取大段数据，进行全量对比，并定位磁盘中第一个非零数据的位置。
def hardcore_verify_sd(img_file_path, offset=0):
    import os
    target_drive = r"\\.\PhysicalDrive1"
    search_range = 5120  # 读取 10 个扇区的大小
    
    try:
        # 1. 读取原始镜像全部内容
        with open(img_file_path, "rb") as f_img:
            original_data = f_img.read()
            img_size = len(original_data)
            
        # 2. 从 SD 卡读取较大范围的数据进行比对
        with open(target_drive, "rb") as sd:
            sd.seek(offset)
            sd_data_chunk = sd.read(search_range)
            
        print(f"Ariel，正在检查偏移量 {offset} 后的 {search_range} 字节...")
        
        # 3. 定位非零数据
        first_nonzero_sd = -1
        for i, byte in enumerate(sd_data_chunk):
            if byte != 0:
                first_nonzero_sd = i
                break
        
        if first_nonzero_sd == -1:
            print("❌ 结果：在该区域内，SD 卡里的数据全部是 00。数据可能根本没写进去。")
        else:
            print(f"✅ 发现数据！SD 卡在偏移量 {offset + first_nonzero_sd} 处出现了第一个非零字节: {sd_data_chunk[first_nonzero_sd:first_nonzero_sd+1].hex().upper()}")
            
            # 4. 尝试局部匹配
            if original_data[:10] in sd_data_chunk:
                match_pos = sd_data_chunk.find(original_data[:10])
                print(f"🚩 找到匹配！你的 .img 数据实际起始于物理偏移量: {offset + match_pos}")
            else:
                print("❗ 警告：虽然发现了数据，但与你的 .img 文件头不匹配。")

    except PermissionError:
        print("错误：请务必以‘管理员身份’运行 PowerShell！")
    except Exception as e:
        print(f"发生错误: {e}")

# 记得加 r
hardcore_verify_sd(r"D:\ece385\final\ece385-final\src\sd\sd_image_small.img", offset=0)
