module Mork
  # this is the default grid!
  DGRID = {
    # default units are millimiters
    page_size: {
      # this is A4
      width:      210,
      height:     297
    }, # page end
    reg_marks: {
      margin:      10,
      radius:       2.5,
      search:      10,
      offset:       2
    }, # reg_marks end
    header: {
      name: {
        top:        5,
        left:       7.5,
        width:    170,
        size:      14,
      },
      title: {
        top:       15,
        left:       7.5,
        width:    180,
        size:      12
      },
      code: {
        top:         5,
        left:      165,
        width:      20,
        size:       14
      },
      signature: {
        top:        30,
        left:        7.5,
        width:     120,
        height:     15,
        size:        7,
        box:      true,
      }
    }, # header end
    items: {
      columns:       4, 
      column_width: 44,
      rows:         30,
      # from the top-left registration mark
      # to the center of the first choice cell
      left:      10.5,
      top:      55.5,
      # between choices
      x_spacing:     7,
      # between rows
      y_spacing:     7,
      # darkened area
      cell_width:    6,
      cell_height:   5,
      # the maximum number of choices per question
      max_cells:     5,
      # font size for the question number and choice letters
      font_size:     9,
      # distance between right side of q num and left side of first choice cell
      number_width:  8,
      # width of question number text box
      number_margin: 2,
    }, # items end
    barcode: {
      bits:         40,
      left:         15,
      width:         3,
      height:        3,
      spacing:       4
    }, # barcode end
    control: {
      top:          40,
      left:        123,
      width:        50,
      size:          9,
      margin:        2.5
    } # control end
  }
end
