require 'spec_helper'

module Mork
  describe SheetPDF do
    let(:content) {
      {
        barcode: 1234566,
        choices: [5] * 120,
        header: {
          name: 'John Doe UI01234',
          title: 'A really serious and difficult test - 18 January 2013',
          code:  '201.48',
          signature: 'Signature'
        }
      }
    }

    it 'assigns the grid to @grid' do
      s = SheetPDF.new(content)
      s.instance_variable_get('@grip').should be_a GridPDF
    end
  
    it 'creates a grid by loading the specified file' do
      s = SheetPDF.new(content, 'spec/samples/layout.yml')
      s.instance_variable_get('@grip').should be_a GridPDF
    end
    
    it 'raises an error with an invalid init parameter' do
      lambda { SheetPDF.new(content, 2) }.should raise_error 'Invalid initialization parameter'
    end
    
    it 'assigns an array to @content' do
      s = SheetPDF.new(content)
      s.instance_variable_get('@content').should be_an Array
    end

    it 'assigns an array of hashes to @content' do
      s = SheetPDF.new(content)
      s.instance_variable_get('@content').first.should be_a Hash
    end

    it 'creates a basic PDF sheet' do
      s = SheetPDF.new(content)
      s.save('spec/out/sheet.pdf')
    end
    
    it 'creates a basic PDF sheet with a code of 15' do
      s = SheetPDF.new(content.merge({barcode: 15}))
      s.save('spec/out/sheet16.pdf')
    end
    
    it 'creates a basic PDF sheet with a code of 666666666666' do
      s = SheetPDF.new(content.merge({barcode: 666666666666}))
      s.save('spec/out/sheet666.pdf')
    end
    
    it 'creates a PDF sheet with the maximum possible barcode' do
      s = SheetPDF.new(content.merge({barcode: 1099511627775}))
      s.save('spec/out/maxcode.pdf')
    end

    it 'creates a PDF sheet with 160 items' do
      s = SheetPDF.new(content.merge({choices: [5] * 160}), 'spec/samples/grid160.yml')
      s.save('spec/out/i160.pdf')
      system 'open spec/out/i160.pdf'
    end

    it 'creates a PDF sheet with unequal choices per item' do
      s = SheetPDF.new(content.merge({choices: [5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1]}), 'spec/samples/layout.yml')
      s.save('spec/out/uneq.pdf')
    end

    it 'creates 20 PDF sheets' do
      c = content
      s = SheetPDF.new([c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c,c])
      s.save('spec/out/p20.pdf')
    end
  end
end

