/*
* (c)  Crown copyright
*  
* You may use and re-use this code free of charge under the terms of the Open Government Licence v3.0.
*  
* https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3
*
*/
package uk.gov.legislation.gateembeddedsample;

import gate.FeatureMap;
import gate.Gate;
import gate.Corpus;
import gate.Factory;
import gate.creole.ResourceInstantiationException;
import gate.creole.SerialAnalyserController;
import gate.util.GateException;
import gate.util.persistence.PersistenceManager;

import org.apache.log4j.PropertyConfigurator;

import java.io.*;
import java.net.URL;

public class GateEmbeddedSample {
  // You must specify the encoding explicitly or GATE may use the wrong one
  public static final String encoding = "UTF-8";

  public static void main(String args[]) throws GateException, IOException {
    File gateHome = null;
    File inputFile = null;
    
    // Need to initialise log4j to see log messages
    PropertyConfigurator.configure(
      GateEmbeddedSample.class.getResourceAsStream("/log4j.properties")
    );

    try {
      gateHome = new File(args[0]);
      assert gateHome.exists() && gateHome.isDirectory();
    } catch (Exception e) {
      System.out.println("Error: you must specify the home directory of the Legislation GATE app as argument 1");
      System.exit(1);
    }

    try {
      inputFile = new File(args[1]);
      assert inputFile.exists() && inputFile.isFile();
    } catch (Exception e) {
      System.out.println("Error: you must specify a valid CLML input file as argument 2");
      System.exit(1);
    }

    // If running inside a sandboxed environment, uncomment the below command
    // to stop GATE from trying to load local configuration information
    // (see https://gate.ac.uk/userguide/sec:gettingstarted:sysprop)
    //Gate.runInSandbox(true);

    Gate.setGateHome(gateHome);
    Gate.setPluginsHome(new File(gateHome, "plugins"));
    Gate.init();

    // This command loads the saved GATE application state, which includes all
    // the plugins (and their configuration) that we use in the pipeline
    SerialAnalyserController application = (SerialAnalyserController) PersistenceManager.loadObjectFromFile(
        new File(gateHome, "LegislationAmendments/legislation-amendments.gapp")
    );

    // You must create a corpus and add a document to it in order to process it
    // in the pipeline
    Corpus corpus = Factory.newCorpus("DocCorpus");

    // File.toURL() is deprecated as it does not escape paths correctly,
    // Java language docs recommend converting to URI then URL instead
    gate.Document document = createGATEDocument(inputFile.toURI().toURL());
    corpus.add(document);

    application.setCorpus(corpus);
    application.execute();

    // Once you've finished with the document, clear the corpus so you can re-use it
    corpus.clear();

    FeatureMap features = document.getFeatures();

    // Here we convert the annotated document to XML and include only the
    // annotations in the "Output" set, which includes the key annotations we
    // want in the final output CLML (Location, Quote, LegAmendment etc.)
    String gatedDocumentXml = document.toXml(document.getAnnotations("Output"));

    // The "xmlContent" document feature contains the set of legislative
    // amendments (i.e. amendments made by this document to other items of
    // legislation) that the GATE pipeline has identified in the CLML
    String changeXml = (String) features.get("xmlContent");

    String docOutputFilename = document.getName() + ".gated.xml";
    String effectsOutputFilename = document.getName() + ".gated-effects.xml";

    // You should clean up a document once you've finished with it
    Factory.deleteResource(document);

    writeStringToFile(docOutputFilename, gatedDocumentXml);
    writeStringToFile(effectsOutputFilename, changeXml);

    System.out.println("done");
  }

  public static gate.Document createGATEDocument(URL url) throws ResourceInstantiationException {
    FeatureMap params = Factory.newFeatureMap();

    // You must explicitly set the encoding or GATE may choose the wrong one
    params.put(gate.Document.DOCUMENT_ENCODING_PARAMETER_NAME, encoding);

    // The "markup-aware" parameter ensures that GATE adds the original markup
    // in the document as annotations, which appears to be necessary for the
    // pipeline to function
    params.put(gate.Document.DOCUMENT_MARKUP_AWARE_PARAMETER_NAME, true);

    // The "preserve content" parameter ensures that GATE preserves the
    // original CLML markup as a feature, which appears to be necessary for
    // the pipeline to function
    params.put(gate.Document.DOCUMENT_PRESERVE_CONTENT_PARAMETER_NAME, true);

    // You also need to set the encoding when creating the document 
    // or some versions of the GATE API will use the wrong encoding
    gate.Document document = Factory.newDocument(url, encoding);
    document.setFeatures(params);

    return document;
  }

  public static void writeStringToFile(String filename, String content) throws IOException {
    try (FileOutputStream fos = new FileOutputStream(new File(filename));
         BufferedOutputStream bos = new BufferedOutputStream(fos);
         OutputStreamWriter out = new OutputStreamWriter(bos, encoding)) {
      out.write(content);
    }
  }
}