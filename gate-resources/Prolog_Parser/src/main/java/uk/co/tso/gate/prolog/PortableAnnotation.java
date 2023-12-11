/*
(c) Crown copyright

You may use and re-use the code in this repository free of charge under the terms of the Open Government Licence

http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2

*/
package uk.co.tso.gate.prolog;

import gate.Annotation;
import gate.AnnotationSet;
import gate.util.InvalidOffsetException;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

/**
 *
 * @author scresswell
 */
@XmlRootElement
public class PortableAnnotation {
    String type;
    long startOffset;
    long endOffset;
    PortableFeatureMap features;
    
    PortableAnnotation() {
        features= new PortableFeatureMap();
    }
    PortableAnnotation(Annotation ann, String text) {
       type= ann.getType();
       startOffset= ann.getStartNode().getOffset();
       endOffset= ann.getEndNode().getOffset();
       features= new PortableFeatureMap(ann.getFeatures());
       if(text!=null&&!text.isEmpty()) features.getMap().put("text",text);
    }
    @XmlAttribute
    public String getType() {
        return type;
    }
    void setType(String type) {
        this.type= type;
    }
    @XmlAttribute
    public long getStartOffset() {
        return startOffset;
    }
    public void setStartOffset(long startOffset) {
        this.startOffset= startOffset;
    }
    @XmlAttribute
    public long getEndOffset() {
        return endOffset;
    }
    public void setEndOffset(long startOffset) {
        this.endOffset= startOffset;
    }
    @XmlElement
    public PortableFeatureMap getFeatures() {
        return features;
    }
    public void setFeatures (PortableFeatureMap features) {
        this.features= features;
    }

    void addToAnnotationSet(AnnotationSet as) throws InvalidOffsetException {
        as.add(startOffset,endOffset,type,features.toFeatureMap());
    }
}
