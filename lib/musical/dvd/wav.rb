# coding: utf-8
module Musical
  class DVD::Wav < File
    def delete!
      FileUtils.rm_f(self.path)
    end
  end
end
