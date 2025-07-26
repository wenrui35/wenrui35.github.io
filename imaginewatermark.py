#我不知道这能不能用
import os
import sys
import math
import shutil
import time
from PIL import Image, ImageDraw

VERSION = "Alpha 1.3"

if VERSION == 10.0 or 10.1 or 10.2:
    print ("没想到有个跟我一样无聊的人发现了这行代码")
    time.sleep(15)
    exit(1)    


def create_backup_dir():
    """创建备份目录"""
    backup_dir = os.path.join(os.getcwd(), "original_backup")
    if not os.path.exists(backup_dir):
        os.makedirs(backup_dir)
    return backup_dir

def backup_original(file_path, backup_dir):
    """备份原始文件"""
    if not os.path.exists(file_path):
        return False
        
    filename = os.path.basename(file_path)
    backup_path = os.path.join(backup_dir, filename)
    
    # 确保备份文件不重复
    counter = 1
    while os.path.exists(backup_path):
        name, ext = os.path.splitext(filename)
        backup_path = os.path.join(backup_dir, f"{name}_{counter}{ext}")
        counter += 1
        
    shutil.copy2(file_path, backup_path)
    return True

def add_watermark(input_path, output_path):
    """核心水印添加函数 (支持PNG、JPG、BMP多种格式)"""
    try:
        # 使用Pillow打开图片
        with Image.open(input_path) as img:
            # 确保图片为RGB模式
            if img.mode != 'RGB':
                img = img.convert('RGB')
            draw = ImageDraw.Draw(img)
            width, height = img.size

            # 水印配置
            watermark_text = "牛马手机壳"
            opacity = 0.35  # 35%透明度
            spacing = 80    # 水印间距
            scale_factor = 0.4  # 缩放到40%
            font_size = int(width * 0.03)  # 字体大小为宽度的3%

            # 尝试加载系统字体，如无法加载则使用默认字体
            try:
                from PIL import ImageFont
                font = ImageFont.truetype("simhei.ttf", font_size)  # 尝试加载黑体
            except:
                font = ImageFont.load_default()

            # 计算文本宽度和高度
            text_width, text_height = draw.textsize(watermark_text, font=font)

            # 添加水印到图片
            for y in range(0, height, spacing):
                for x in range(0, width, spacing):
                    # 计算旋转后的位置
                    rad = math.radians(30)  # 30度旋转
                    rotated_x = int(x * math.cos(rad) - y * math.sin(rad))
                    rotated_y = int(x * math.sin(rad) + y * math.cos(rad))

                    # 绘制水印文本
                    draw.text((rotated_x, rotated_y), watermark_text, font=font,
                              fill=(int(255 * opacity), int(255 * opacity), int(255 * opacity), int(255 * opacity)))

            # 图片压缩（缩放到原尺寸40%）
            new_width = int(width * scale_factor)
            new_height = int(height * scale_factor)
            img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)

            # 保存图片（根据输出路径扩展名自动选择格式）
            img.save(output_path)
            return True, "水印添加成功"

    except Exception as e:
        return False, f"处理错误: {str(e)}"

def process_directory(directory):
    """处理目录下所有BMP文件"""
    backup_dir = create_backup_dir()
    processed = 0
    errors = []
    
    for filename in os.listdir(directory):
        if filename.lower().endswith(('.bmp', '.png', '.jpg', '.jpeg', '.gif')):
            input_path = os.path.join(directory, filename)
            output_path = os.path.join(directory, f"wm_{filename}")
            
            # 备份原始文件
            if not backup_original(input_path, backup_dir):
                errors.append(f"{filename}: 备份失败")
                continue
                
            # 添加水印
            success, message = add_watermark(input_path, output_path)
            if success:
                processed += 1
            else:
                errors.append(f"{filename}: {message}")
    
    print(f"\n处理完成! 成功处理 {processed} 个文件")
    if errors:
        print("\n错误信息:")
        for error in errors:
            print(f"  - {error}")
    input("\n按回车键返回主菜单...")

def process_single_file():
    """处理单个文件"""
    while True:
        print("\n" + "="*50)
        print("单个文件处理模式")
        print("="*50)
        print("请将要处理的BMP文件放在程序同一目录下")
        print("输入文件全名(包括扩展名)，或输入 'back' 返回主菜单")
        
        filename = input("\n文件名: ").strip()
        if filename.lower() == 'back':
            return
            
        if not filename.lower().endswith(('.bmp', '.png', '.jpg', '.jpeg', '.gif')):
            print("错误: 只支持BMP、PNG、JPG、JPEG、GIF格式文件")
            continue
            
        input_path = os.path.join(os.getcwd(), filename)
        if not os.path.exists(input_path):
            print(f"错误: 文件 {filename} 不存在")
            continue
            
        output_path = os.path.join(os.getcwd(), f"wm_{filename}")
        backup_dir = create_backup_dir()
        
        # 备份原始文件
        if not backup_original(input_path, backup_dir):
            print("错误: 备份文件失败")
            continue
            
        # 添加水印
        success, message = add_watermark(input_path, output_path)
        if success:
            print(f"\n水印添加成功! 输出文件: wm_{filename}")
        else:
            print(f"\n处理失败: {message}")
            
        input("\n按回车键继续...")

def main_menu():
    """主控制台菜单"""
    while True:
        # 清屏
        if os.name == 'nt':
            os.system('cls')
        else:
            os.system('clear')
            
        # 显示标题和选项
        print("="*60)
        print(f"牛马手机壳图片处理工具 {VERSION}".center(60))
        print("="*60)
        print("\n功能选项:")
        print("  1. 处理当前目录下的所有BMP文件")
        print("  2. 处理单个BMP文件")
        print("  3. 退出程序")
        
        # 获取用户选择
        choice = input("\n请选择操作 (1-3): ").strip()
        
        if choice == '1':
            process_directory(os.getcwd())
        elif choice == '2':
            process_single_file()
        elif choice == '3':
            print("\n感谢使用牛马手机壳图片处理工具!")
            sys.exit(0)
        else:
            print("\n无效选择，请输入1-3之间的数字")
            input("按回车键继续...")

if __name__ == "__main__":
    print(f"启动牛马手机壳图片处理工具 {VERSION}")
    print("提示: 本程序仅支持24位BMP格式图片")
    input("按回车键进入主菜单...")
    main_menu()

def create_backup_dir():
    """创建备份目录"""
    backup_dir = os.path.join(os.getcwd(), "backup")
    if not os.path.exists(backup_dir):
        os.makedirs(backup_dir)
    return backup_dir

def backup_original(input_path, backup_dir):
    """备份原始文件"""
    backup_path = os.path.join(backup_dir, os.path.basename(input_path))
    try:
        shutil.copy2(input_path, backup_path)
        return True
    except:
        return False
def restore_original(backup_dir):
    """从备份目录恢复原始文件"""
    for filename in os.listdir(backup_dir):
        backup_path = os.path.join(backup_dir, filename)
        try:
            shutil.copy2(backup_path, os.path.join(os.getcwd(), filename))
        except:
            pass



