# coding: utf-8
module Musical
  class DVD::Wav < File
    def expand_path
      File.expand_path(self.path)
    end

    def delete!
      FileUtils.rm_f(self.expand_path)
    end
  end
end
