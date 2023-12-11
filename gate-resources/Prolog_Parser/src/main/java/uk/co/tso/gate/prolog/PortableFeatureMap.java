/*
(c) Crown copyright

You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/
package uk.co.tso.gate.prolog;

import gate.FeatureMap;
import gate.util.SimpleFeatureMapImpl;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeMap;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author scresswell
 */
@XmlRootElement
public class PortableFeatureMap {

    Map<String, String> map;
    Map<String, PortableList> lvm; // list-valued map

    PortableFeatureMap() {
        map= new TreeMap<>();
        lvm= new TreeMap<>();
    }
    PortableFeatureMap(FeatureMap fm) {
        map= new TreeMap<>();
        lvm= new TreeMap<>();
        for (Entry<Object, Object> entry : fm.entrySet()) {
            String key= entry.getKey().toString();
            Object value= entry.getValue();
            if(value instanceof List<?>){
                PortableList plist= new PortableList((List<Object>) value);
                lvm.put(key, plist);                
            } else {
                if(value!=null) {
                    String text= value.toString();
                    if(!text.isEmpty()) {
                        map.put(key,value.toString());
                    }
                }
            }
        }
    }

    @XmlElement
    public Map<String,String> getMap() {
        return map;
    }
    void setMap(Map<String,String> map) {
        this.map= map;
    }

    @XmlElement
    public Map<String,PortableList> getListValuedMap() {
        return lvm;
    }
    void setListValuedMap(Map<String,PortableList> lvm) {
        this.lvm= lvm;
    }

    FeatureMap toFeatureMap() {
        FeatureMap fm= new SimpleFeatureMapImpl();
        for (Entry<String, String> entry : map.entrySet()) {
            String key= entry.getKey();
            String value= entry.getValue().toString();
            fm.put(key, value);
        }
        for (Entry<String, PortableList> entry : lvm.entrySet()) {
            String key= entry.getKey();
            PortableList value= entry.getValue();
            fm.put(key, value.getList());
        }
        return fm;
    }
}
