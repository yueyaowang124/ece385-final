import math

# 概述：生成 256 点、16位精度的正弦波查找表 hex 文件
# 逻辑：将 sin(2*pi*i/256) 映射到 -32768 到 32767 之间，并转换为十六进制补码

def generate_sine_hex(filename="sine_lut.hex"):
    points = 256          # 查找表深度，对应 dds.sv 中的 sine_lut [0:255]
    bit_width = 16        # 16位有符号数宽度
    max_val = 32767       # 16位有符号正数最大值 (2^15 - 1)
    
    lines = []
    
    for i in range(points):
        # 1. 计算正弦值
        raw_v = math.sin(2 * math.pi * i / points)
        
        # 2. 缩放到 16 位整数范围
        v = int(raw_v * max_val)
        
        # 3. 处理负数的补码 (v &= 0xFFFF)
        # 在 Python 中，负数按位与 0xFFFF 后会自动转为 16 进制补码形式
        v_signed = v & 0xFFFF
        
        # 4. 格式化为 4 位大写十六进制字符串，不带 0x
        lines.append(f"{v_signed:04X}")
    
    # 将结果写入文件，每行一个数
    with open(filename, "w") as f:
        f.write("\n".join(lines))
    
    print(f"成功！已在当前目录下生成: {filename}")
    print(f"前 5 行预览: {lines[:5]}")

if __name__ == "__main__":
    generate_sine_hex()