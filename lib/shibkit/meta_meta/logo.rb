## @author    Pete Birkinshaw (<pete@digitalidentitylabs.com>)
## Copyright: Copyright (c) 2011 Digital Identity Ltd.
## License:   Apache License, Version 2.0

## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
## 
##     http://www.apache.org/licenses/LICENSE-2.0
## 
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##


module Shibkit
  class MetaMeta

    ## Class to represent technical or suppor contact details for an entity
    class Logo < MetadataItem
      
      require 'shibkit/meta_meta/metadata_item'
      
      require 'shibkit/meta_meta/mixin/cached_downloads'
      include Shibkit::MetaMeta::Mixin::CachedDownloads
      
      ## Element and attribute used to select XML for new objects
      ROOT_ELEMENT = 'Logo'
      TARGET_ATTR  = 'width'
      REQUIRED_QUACKS = [:location]
      
      ## URI of the entity this logo is associated with
      attr_accessor :entity
      
      ## Height of the image as declared in XML
      attr_accessor :height
      
      ## Width of the image as declared in XML
      attr_accessor :width
      
      ## URL of the image
      attr_accessor :location   
      
      ## Language of the logo
      attr_accessor :language
      
      ## Calculated size of the image (:tiny :small :medium :large, etc)
      ## I'm not sure about these.
      def size
        
        return case 
        when pixels <= (16*16)
          :tiny
        when pixels <= (32*32)
          :small
        when pixels <= (64*64)
          :icon
        when pixels <= (4200..6200)
          :default
        when pixels <= (128*128)
          :medium
        when pixels <= (256*256)
          :large
        when pixels <= (512*512)
          :huge
        else
          :silly
        end
        
      end
      
      ## Returns number of pixels
      def pixels
        
        return width.to_i * height.to_i
        
      end
      
      ## Returns :square, :portrait or :landscape
      def shape
        
        return :default   if (75..85).include(width) and (55..65).include(height)
        return :square    if width == height ## TODO: Needs a bit of tolerance for small differences
        return :portrait  if height > width
        return :landscape if width > height
        
        
        ## Possibly running in the nightmare corpse-city of R'lyeh
        raise "Geometry of logo is abnormal, non-Euclidean, and loathsomely redolent of spheres and dimensions apart from ours."
        
      end
      
      ## HTTPS resource? 
      def ssl?
        
        return location =~ /^https/ ? true : false
        
      end
      
      ## PNG image? Convenience method since these are probably a better choice than JPEGs
      ## Not accurate...
      def png?
        
        return false if location.empty?
        
        #if @local_file 
        #
        # # ... 
        #
        #end
        
        return true if location =~ /[.]png$/
        
        begin
          response = RestClient.head(location)
          return true if response.headers['content-type'] == 'image/png'
        rescue
          return false
        end
        
        return false
        
      end
      
      ## Logo is within recommended size range?
      def acceptable_size?
        
        return true if width > 50 and
          width < 100 and
          height > 50 and
          height < 100
        
      end
      
      ## Download and cache the image, returning a filehandle
      def download
      
        
      
      end
      
      ## Filehandle for the local, downloaded file. Will download.
      def local_file
      
        
      
      end
    
      ## Download the file and update this object based on real characteristics
      def confirm_attribs
      
        
      
      end
      
      private
      
      ## Build the logo object from a suitable chunk of XML
      def parse_xml
        
        if @xml and @xml.content
          
          self.location = @xml.content.strip || nil
          self.height   = @xml['height'] ? @xml['height'].to_i : 0 
          self.width    = @xml['width']  ? @xml['width'].to_i  : 0
          lang          = @xml['xml:lang'] || :en
        
        end
      end
    end
  end
end
