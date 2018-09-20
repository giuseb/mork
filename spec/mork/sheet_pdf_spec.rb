require 'spec_helper'

module Mork
  describe SheetPDF, focus: true do
    let(:content) {
      {
        barcode: 183251937962,
        choices: [5] * 120,
        header: {
          title: 'A serious, difficult test - 31 December 1999'
        }
      }
    }
    def sp(cnt: {title: 'Hello world'}, grip: nil)
      SheetPDF.new cnt, grip
    end

    it 'assigns the grid to @grid' do
      expect(sp.instance_variable_get('@grip')).to be_a GridPDF
    end

    it 'uses a yaml file as content' do
      s = 'spec/samples/content.yml'
      c = sp(cnt: s).instance_variable_get('@content')[0][:choices]
      expect(c).to eq [5,5,5,4,5,5,5]
    end

    it 'creates a grid by loading the specified file' do
      s = 'spec/samples/layout.yml'
      expect(sp(grip: s).instance_variable_get('@grip')).to be_a GridPDF
    end

    it 'raises an error with an invalid init parameter' do
      expect { SheetPDF.new(content, 2) }.to raise_error ArgumentError
    end

    it 'raises an error if a header part is not described in the layout' do
      expect {
        sp(cnt: {header: {dummy: 'yes I am'}})
        }.to raise_error ArgumentError
    end

    it 'assigns an array to @content' do
      expect(sp.instance_variable_get('@content')).to be_an Array
    end

    it 'assigns an array of hashes to @content' do
      expect(sp.instance_variable_get('@content').first).to be_a Hash
    end

    it 'creates a minimal PDF sheet' do
      s = SheetPDF.new({})
      s.save dest 'minimal'
    end

    it 'creates a PDF sheet with a big barcode' do
      s = SheetPDF.new({barcode: 183251937962})
      s.save dest 'bigbarcode'
    end

    it 'creates a PDF sheet with several boxed header elements' do
      h = {
        name: 'John Doe UI354320',
        title: 'A serious, difficult test - 31 December 1999',
        code: '201.48',
        signature: 'Signature'
      }
      s = SheetPDF.new({header: h, barcode: 2384685871}, 'spec/samples/standard.yml')
      s.save dest 'standard'
    end

    it 'creates a PDF sheet with several header elements' do
      h = {
        name: lorem,
        title: lorem,
        code: '1000.10.100',
        signature: 'Signature'
      }
      s = SheetPDF.new({header: h}, 'spec/samples/boxy.yml')
      s.save dest 'boxy'
    end

    it 'creates a PDF sheet with the maximum possible barcode for 38 bits' do
      c = {
        barcode: 274877906943,
        header: {
          title: 'The maximum barcode for 38 bits is 274877906943'
        }
      }
      s = SheetPDF.new(c)
      s.save dest 'maxcode'
    end

    it 'creates a PDF sheet with 160 items' do
      c = { header: {title: '160 items, tighter layout'}, choices: [5]*160}
      sp(cnt: c, grip: 'spec/samples/grid160.yml').save dest 'i160'
    end

    it 'creates a PDF sheet with unequal choices per item' do
      c = {
        choices: [5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1],
        header: {
          title: 'Each question can have an arbitrary number of choices'
        }
      }
      SheetPDF.new(c).save dest('uneq')
    end

    it 'creates 20 PDF sheets' do
      c = 20.times.map do |x|
        content.merge({ header: {title: "Test #{x+1}"}, barcode: x})
      end
      SheetPDF.new(c).save dest('p20')
    end

    it 'creates blank pages for duplex printing' do
      c = 5.times.map do |x|
        content.merge({ header: {title: "Test #{x+1}"}, barcode: x})
      end
      SheetPDF.new(c, nil, true).save dest('duplex5')
    end

    it 'creates a PDF with the maximum possible choice cells if none are specified' do
      ct = [{}, {choices: [3]*20}]
      SheetPDF.new(ct).save dest('nocontent')
    end

    def dest(fname)
      "spec/out/pdf/#{fname}.pdf"
    end
  end
end

