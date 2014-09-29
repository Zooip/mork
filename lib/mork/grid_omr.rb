require 'mork/grid'

module Mork
  class GridOMR < Grid
    def initialize(page_width, page_height, options=nil)
      super options
      @px = page_width.to_f
      @py = page_height.to_f
    end
    
    def barcode_bit_areas(code = 2**barcode_bits-1)
      barcode_bits.times.collect { |b| barcode_bit_area b }
    end
    
    # ====================================================
    # = Returning {x, y, w, h} hashes for area locations =
    # ====================================================
    def choice_cell_area(q, c)
      {
        x: (cx * cell_x(q,c)).round,
        y: (cy * cell_y(q)  ).round,
        w: (cx * cell_width ).round,
        h: (cy * cell_height).round
      }
    end
    
    def calibration_cell_areas
      rows.times.collect do |q|
        {
          x: (cx * cal_cell_x ).round,
          y: (cy * cell_y(q)  ).round,
          w: (cx * cell_width ).round,
          h: (cy * cell_height).round
        }
      end
    end
    
    def barcode_bit_area(bit)
      {
        x: (cx * barcode_bit_x(bit)).round,
        y: (cy * barcode_y         ).round,
        w: (cx * barcode_width     ).round,
        h: (cy * barcode_height    ).round
      }
    end
    
    # the 4 values needed to locate a single registration mark
    # 
    def rm_search_area(corner, i)
      {
        x: (ppu_x * rmx(corner, i)).round,
        y: (ppu_y * rmy(corner, i)).round,
        w: (ppu_x * (reg_search + reg_radius * i)).round,
        h: (ppu_y * (reg_search + reg_radius * i)).round
      }
    end
    
    # a safe distance to determine
    def rm_edgy_x()                (ppu_x * reg_radius).round + 5    end
    def rm_edgy_y()                (ppu_y * reg_radius).round + 5    end
    # areas on the sheet that are certainly white/black
    def paper_white_area()         barcode_bit_area -1               end
    def ink_black_area()           barcode_bit_area  0               end
    def max_choices_per_question() @params[:items][:max_cells].to_i  end
    def rm_max_search_area_side()  (ppu_x * page_width / 4).round    end
    
    private
    
    def cx()    @px / reg_frame_width  end
    def cy()    @py / reg_frame_height end
    def ppu_x() @px / page_width       end
    def ppu_y() @py / page_height      end
      
    # finding the width of the registration area based on iteration
    def rmx(corner, i)
      case corner
      when :tl; reg_off
      when :tr; page_width - reg_search - reg_off - reg_radius * i
      when :br; page_width - reg_search - reg_off - reg_radius * i
      when :bl; reg_off
      end
    end
  
    # finding the height of the registration area based on iteration
    def rmy(corner, i)
      case corner
      when :tl; reg_off
      when :tr; reg_off
      when :br; page_height - reg_search - reg_off - reg_radius * i
      when :bl; page_height - reg_search - reg_off - reg_radius * i
      end
    end
  end
end