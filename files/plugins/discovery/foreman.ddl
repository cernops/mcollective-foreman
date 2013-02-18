metadata    :name        => "foreman", 
            :description => "Foreman based discovery for node information", 
            :author      => "Daniel Lobato Garcia <me@daniellobato.me>", 
            :license     => "GPL", 
            :version     => "0.1", 
            :url         => "http://www.github.com/elobato/foreman-mcollective", 
            :timeout     => 0 
 
discovery do 
    capabilities :identity 
end
