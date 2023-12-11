/*
(c) Crown copyright

You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/

package uk.co.tso.gate.prolog;

import gate.Annotation;
import gate.AnnotationSet;
import gate.util.InvalidOffsetException;
import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author scresswell
 */
@XmlRootElement(name="list")
public class PortableList {
    private List<String> list;
    public PortableList() {
        list= new ArrayList<>();
    }
    public PortableList(List<Object> olist) {
        this.list = new ArrayList<String>();
        for(Object ob : olist) {
			this.list.add(ob.toString());
        }
    }
    @XmlElement(name="item")
    List<String> getList() {
        return list;
    }
    void setList(List<String> list) {
        this.list= list;
    }
}
