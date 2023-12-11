/*
(c) Crown copyright

You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/
package uk.co.tso.gate.prolog;

import gate.Annotation;
import gate.AnnotationSet;
import gate.Document;
import gate.util.InvalidOffsetException;
import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author scresswell
 */
@XmlRootElement(name="annotationSet")
public class PortableAnnotationSet {
    private List<PortableAnnotation> as;
    public PortableAnnotationSet() {
        as= new ArrayList<>();
    }
    // Construct PortableAnnotationSet from gate.AnnotationSet
    public PortableAnnotationSet(AnnotationSet gas) {
        Document doc= gas.getDocument();
        this.as = new ArrayList<PortableAnnotation>();
        for(Annotation gann : gate.Utils.inDocumentOrder(gas)) {
            String text= gate.Utils.cleanStringFor(doc, gann);
			text=text.replaceAll("[\\s\\u2009]","_"); // deal with weird whitespace
            if(text.length()>50) 
                text=text.substring(0, 50)+"...";
            else if(text.isEmpty()) 
                text= "_";
            //System.out.println(gann.getStartNode().getOffset()+" "+gann.getEndNode().getOffset()+" "+gann.getType()+" "+text);
            PortableAnnotation pann= new PortableAnnotation(gann,text);
            as.add(pann);
        }
    }
    @XmlElement(name="annotation")
    List<PortableAnnotation> getAS() {
        return as;
    }
    void setAS(List<PortableAnnotation> as) {
        this.as= as;
    }
    public void addToAnnotationSet(AnnotationSet gas) throws InvalidOffsetException {
        //AnnotationSet gas;
        //gas = new AnnotationSetImpl(doc);
        for(PortableAnnotation pann : as) {
            pann.addToAnnotationSet(gas);
        }
        //return gas;
    }
}
