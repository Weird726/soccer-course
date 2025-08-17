 // 指定2d元素着色器，spatial是用于3D元素着色器
 //  着色器需要进行拖拽才能应用
shader_type canvas_item;

 // 为调色版分签
group_uniforms Palettes;
 //皮肤调色板
uniform sampler2D skin_palette;
 // 先指定类型，团队调色板
uniform sampler2D team_palette;
group_uniforms;

 // 添加我们想定位的行，无论玩家是要浅色，还是深色,下拉列表，提示枚举
uniform int skin_color : hint_enum("Light", "Medium", "Dark");
 // 整数类型指定国家类型
uniform int team_color;

 // 创建一个此函数用于转换像素位置来为UV提供精确坐标
vec2 px_to_uv(ivec2 pos, ivec2 tex_size) {
	return vec2(
		(float(pos[0]) + 0.5) / float(tex_size[0]),
		(float(pos[1]) + 0.5) / float(tex_size[1])
	);
}

 // 返回类型，此类型接受三个参数(原始颜色，图像调色板，行）
vec4 get_palette_color(vec4 color, sampler2D palette, int selection) {
	 // 细节层级
	ivec2 tex_size = textureSize(palette, 0);
	 // 创建一个for循环用于遍历,用于遍历宽度
	for (int i=0; i<tex_size[0]; i++) {
		vec2 uv_color_ref = px_to_uv(ivec2(i, 0), tex_size);
		vec4 color_ref = texture(palette,uv_color_ref);
		 // 比较片段着色器与传入的颜色
		if (color == color_ref) {
			vec2 uv_color_dest = px_to_uv(ivec2(i, selection), tex_size);
			return texture(palette, uv_color_dest);
		}
	}
	 // 此参数用于查找（调色板的参数，查找的位置UV坐标，U宽V高，用半径思路来表达，它的二分之一更为确切）
	 //texture(palette, vec2(4, 3));
	 // 返回传入的颜色
	return color;
}

void fragment() {
	 // 传递调色板，传递颜色（现在只是返回以上传递的相同颜色)
	COLOR = get_palette_color(COLOR, team_palette, team_color);
	// 首先检查皮肤颜色是否大于0
	if (skin_color > 0) {
		// 用肤色来获取调色板颜色
		COLOR = get_palette_color(COLOR, skin_palette, skin_color);
	}
}

/*void fragment() {
	// COLOR是一个可以读取或写入的属性（四维向量，拥有四个属性，红色，绿色，蓝色和透明度，所有取值范围都是0-1）
	// 判断如果我的COLOR.a属性为0，则执行这段代码
	if (COLOR.a == 0.0)
	COLOR = vec4(1.0, 1.0, 1.0, 1.0);
}*/
