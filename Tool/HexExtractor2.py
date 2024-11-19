def parse_verilog_init_file(file_path):
    data_dict = {}  # 存储地址和对应数据
    current_address = None

    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if line.startswith('@'):  # 识别地址行
                current_address = int(line[2:], 16)  # 解析地址
                # current_address *= 4  # 解析地址
            elif current_address is not None:  # 数据行
                # 将数据分割为字节并存储
                bytes_data = line.split()
                for byte in bytes_data:
                    data_dict[current_address] = byte
                    current_address += 1

    return data_dict


def fill_and_split(data_dict, start_address, end_address):
    """
    填充地址范围内的空白为 00，并按字节位置分组。
    """
    split_data = [[] for _ in range(4)]  # 初始化 4 个列表

    for addr in range(start_address, end_address):
        byte = data_dict.get(addr, '00')  # 如果地址没有数据，填充为 '00'
        group_index = addr % 4
        split_data[group_index].append(byte)

    return split_data


def main():
    # 输入文件路径
    input_file = 'test.v'  # 替换为你的文件路径
    output_file = 'ram'

    file_names = [
        f'{output_file}0.bin',
        f'{output_file}1.bin',
        f'{output_file}2.bin',
        f'{output_file}3.bin'
    ]

    # 解析初始化文件
    data_dict = parse_verilog_init_file(input_file)

    # 设置默认值
    start_address = 0x00000000  # 默认起始地址
    address_range = 16384 * 4  # 默认范围为 8192 字节
    # 计算 end_address
    end_address = start_address + address_range
    split_data = fill_and_split(data_dict, start_address, end_address)

    # 将数据以字符串形式写入文件
    for i, file_name in enumerate(file_names):
        with open(file_name, 'w') as file:
            for byte in split_data[i]:
                file.write(f"{byte}\n")

    with open("ram.hex", 'w') as file:
        for index in range(len(split_data[0])):
            file.write(f"{split_data[0][index]}{split_data[1][index]}{split_data[2][index]}{split_data[3][index]}\n")

    print(f"{', '.join(file_names)}")


if __name__ == "__main__":
    main()
