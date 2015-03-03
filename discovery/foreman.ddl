metadata    :name        => "foreman", 
            :description => "Foreman based discovery for node information", 
            :author      => "Daniel Lobato Garcia <me@daniellobato.me>", 
            :license     => "GPL", 
            :version     => "0.6", 
            :url         => "http://www.github.com/cernops/foreman-mcollective", 
            :timeout     => 0 
 
discovery do 
    capabilities :identity 
end
