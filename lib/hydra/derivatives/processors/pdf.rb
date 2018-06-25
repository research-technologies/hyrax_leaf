
# frozen_string_literal: true

module Hydra
  module Derivatives
    module Processors
      class Pdf < Processor
        include ShellBasedProcessor

        # Use ImageMagick convert from the command line to create thumbnails for PDFs.
        # Using MiniMagick to create thumbnails from PDFs is slow due to it running the identify command.
        # This pdf processor calls convert from the command line, improving speeds from ~2m to ~1s.

        def process
          format = directives.fetch(:format, 'jpg')
          encode_file(format, directives)
        end

        class << self
          # Use IM convert
          # VIPS config provided; VIPS creates much smaller images
          def encode(path, options, output_file)
            # Alternative VIPS config
            # size = options[:size].blank? ? '' : "--size #{options[:size]}"
            # quality = options[:quality].blank? ? '' : "[Q=#{options[:quality]}]"
            # command = "vipsthumbnail #{Shellwords.escape(path)} -o #{output_file}#{quality} #{size}"
            # Using ImageMagick
            size = options[:size].blank? ? '' : "-resize #{options[:size]}"
            quality = options[:quality].blank? ? '' : "-quality #{options[:quality]}"
            layer = options.fetch(:layer, 0)
            command = "convert #{Shellwords.escape(path)}[#{layer}] #{size} #{quality} -layers flatten #{output_file}"
            Logger.debug("Executing #{command}")
            execute command
          end
        end
      end
    end
  end
end
