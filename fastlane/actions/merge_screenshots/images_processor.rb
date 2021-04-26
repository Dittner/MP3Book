require 'vips'
require 'yaml'
require 'fileutils'

class NilClass
  def [](_key)
    nil
  end
end

class String
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def brown;          "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_brown;       "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end

class ImagesProcessor
  def initialize(root)
    @root = root
  end
    
  def run(config_path)
    puts "ImagesProcessor.run with config = #{config_path}".magenta
    config = load_and_check_config config_path
    languages = config['languages']
    languages.each do |locale|
      img = merge_layers config, locale
      store img, config, locale
    end
  end

  def hex_color_to_rgb(hex)
    # rgb = hex.match(/^#(..)(..)(..)$/).captures.map(&:hex)
    [hex >> 16 & 0xFF, hex >> 8 & 0xFF, hex & 0xFF]
  end

  def load_and_check_config(config_path)
    raise 'The Ruby script requires config file. To read more use --help' if config_path.nil?
    raise 'Config file should be yml' if File.extname(config_path) != '.yml'

    YAML.load(File.open(config_path))
  end

  def image_move(bg, img, layer)
    pos_x = layer['position']['x'] || 0
    pos_y = layer['position']['y'] || 0

    bg.composite img, 'over', x: pos_x, y: pos_y
  end

  def image_apply_mask(img, layer)
    if layer['mask'].nil?
      img
    else
      mask_path = @root + layer['mask']
      mask = Vips::Image.new_from_file mask_path
      mask = mask.add_alpha if mask.bands < 4
      mask = mask.colourspace('srgb')
      mask.composite img, 'in', x: 0, y: 0
    end
  end

  def image_resize(img, layer)
    if layer['size'].nil?
      img
    else
      width = layer['size']['width']
      height = layer['size']['height']
      img.thumbnail_image width, height: height
    end
  end

  def image_rotate(img, layer)
    layer['rotate'].nil? ? img : img.rotate(layer['rotate'], :interpolate => Vips::Interpolate.new(:vsqbs))
  end

  def image_apply_shadow(bg, img, layer)
    if layer['shadow'].nil?
      bg
    else
      sigma = layer['shadow']['sigma'] || 1
      dx = layer['shadow']['dx'] || 1
      dy = layer['shadow']['dy'] || 1
      alpha = layer['shadow']['alpha'] || 0.5
      color = [0, 0, 0, (255 * alpha).to_i]
      pos_x = layer['position']['x'] || 0
      pos_y = layer['position']['y'] || 0

      wid, hei = img.size

      canvas = Vips::Image.black wid + dx, hei + dy, bands: 3
      canvas = canvas.new_from_image([0, 0, 0, 0]).copy(interpretation: 'srgb')
      shadow = img.new_from_image(color).copy(interpretation: :srgb)
      shadow = img.composite shadow, 'in', x: 0, y: 0
      canvas = canvas.composite shadow, 'over', x: 0, y: 0
      canvas = canvas.gaussblur sigma
      bg.composite canvas, 'over', x: pos_x + dx, y: pos_y + dy
    end
  end

  def text_rasterize(bg, text, layer)
    raise "Config file, #{layer_name} has not the required param <font>" if layer['font'].nil?
    raise "Config file, #{layer_name} has not the required param <fontfile>" if layer['fontfile'].nil?

    color = hex_color_to_rgb(layer['color'] || 0)
    width = layer['width'] || 10_000
    font = layer['font']
    fontfile = @root + layer['fontfile']
    align = layer['align'] || 'low'
    pos_x = layer['position']['x'] || 0
    pos_y = layer['position']['y'] || 0

    text_mask = Vips::Image.text text, width: width, fontfile: fontfile, font: font, align: align
    rgb = text_mask.new_from_image(color).copy(interpretation: 'srgb')
    text_img = rgb.bandjoin(text_mask)

    offset = case align
             when 'low'
               0
             when 'centre'
               (width - text_img.width) / 2
             when 'high'
               (width - text_img.width)
             end

    bg.composite text_img, 'over', x: pos_x + offset, y: pos_y
  end

  def merge_layers(config, locale)
    canvas_width = config['canvas_width']
    canvas_height = config['canvas_height']

    raise 'Config file has not the required param <canvas_width>' if canvas_width.nil?
    raise 'Config file has not the required param <canvas_height>' if canvas_height.nil?
    raise 'The param <canvas_width> is invalid' if canvas_width <= 0
    raise 'The param <canvas_height> is invalid' if canvas_height <= 0

    res = Vips::Image.black canvas_width, canvas_height, bands: 3
    res = res.new_from_image([0, 0, 0, 0]).copy(interpretation: 'srgb')
    puts "LOCALE #{locale}"
    puts "--transparent bg w/h = #{canvas_width}/#{canvas_height}".blue

    layer_num = 0
    layer_name = 'layer0'
    until config[layer_name].nil?
      puts "--#{layer_name}".blue
      layer = config[layer_name]

      if !layer['image'].nil?
        img_path = layer['image'].is_a?(Hash) ? @root + layer['image'][locale] : @root + layer['image']
        img = Vips::Image.new_from_file img_path
        img = img.add_alpha if img.bands < 4
        img.colourspace('srgb')
        img = image_apply_mask img, layer
        img = image_resize img, layer
        img = image_rotate img, layer
        res = image_apply_shadow res, img, layer
        res = image_move res, img, layer

      elsif !layer['text'].nil?
        text = layer['text'].is_a?(Hash) ? layer['text'][locale] : layer['text']
        res = text_rasterize res, text, layer
      else
        raise "Config file, #{layer_name} has not the required param <image> or <text>"
      end

      layer_num += 1
      layer_name = "layer#{layer_num}"
    end
    res
  end

  def store(image, config, locale)
    raise 'Config file has not the required param <output>' if config['output'].nil?
    raise 'Config file has not the required param <output.frame>' if config['output']['frame'].nil?
    raise "Config file has not the required param <output.#{locale}>" if config['output'][locale].nil?

    folder = config['output']['folder'] || ""
    frame = config['output']['frame']
    canvas_height = config['canvas_height']
    output_files = config['output'][locale]

    indexes = (0..output_files.length - 1).to_a
    indexes.each do |index|
      file_path = @root + folder + locale + "/" + output_files[index]
      puts "--writing file <#{file_path}>".green
      dirname = File.dirname(file_path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

      fragment = image.extract_area index * frame, 0, frame, canvas_height
      fragment = fragment.flatten if fragment.has_alpha?
      fragment.write_to_file file_path
    end
  end
end
