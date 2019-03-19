module Hydra
  module Derivatives
    class PdfDerivatives < Runner
      def self.processor_class
        Processors::Pdf
      end
    end
  end
end
