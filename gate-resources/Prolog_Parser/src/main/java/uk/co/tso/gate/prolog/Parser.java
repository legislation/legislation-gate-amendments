/*
 *  Parser.java
 *
 * Adapted from code
 * Copyright (c) 2000-2012, The University of Sheffield.
 *
 * This file is part of GATE (see http://gate.ac.uk/), and is free
 * software, licenced under the GNU Library General Public License,
 * Version 3, 29 June 2007.
 *
 * A copy of this licence is included in the distribution in the file
 * LICENCE.txt, and is also available at http://gate.ac.uk/gate/licence.html.
 *
 *  scresswell, 18/10/2018
 *
 * For details on the configuration options, see the user guide:
 * http://gate.ac.uk/cgi-bin/userguide/sec:creole-model:config
 */
package uk.co.tso.gate.prolog;

import gate.*;
import gate.creole.*;
import gate.creole.metadata.*;
import gate.util.*;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URL;
import java.net.URISyntaxException;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.UUID;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import org.apache.commons.io.FileUtils;

import gate.util.ProcessManager;


/**
 * This class is the implementation of the resource PROLOG PARSER.
 */
@CreoleResource(name = "Prolog Parser",
        comment = "TSO Prolog chart parser")
public class Parser extends AbstractLanguageAnalyser
        implements ProcessingResource {

    private String inputASName;
    private String outputASName;
    private URL prologProgram;
    private Boolean changesFlag;
    private String overrideTempDir;
    private String tempDir;
	private String overrideSwiPrologExecutable;
	private String swiPrologExecutable;
	private Boolean overrideRetainTempFiles;
	private Boolean retainTempFiles;

    public Resource init() throws ResourceInstantiationException {
		// Defaults for executable location
		if(overrideSwiPrologExecutable==null) {
			if(System.getProperty("os.name").toLowerCase().startsWith("windows")) {
				swiPrologExecutable= "C:/Program Files/swipl/bin/swipl.exe";
			}
			else {
				swiPrologExecutable= "swipl";
			}
		} else {
			swiPrologExecutable= overrideSwiPrologExecutable;
		}

		// Default for retaining temp files (don't)
		if(overrideRetainTempFiles==null)
			retainTempFiles= false;
		else
			retainTempFiles= overrideRetainTempFiles;

		// Default for temp dir
		if(overrideTempDir==null) {
			tempDir= System.getProperty("java.io.tmpdir");
		} else {
			tempDir= overrideTempDir;
		}
		if(changesFlag==null) changesFlag= false;
		return this;
    }

    public void execute() throws ExecutionException {
        System.out.println("Running Prolog Parser");
        if (document == null) {
            throw new ExecutionException("No document for Prolog_Parser");
        }
        AnnotationSet ias;
        if ((inputASName == null) || (inputASName.equals(""))) {
            ias = document.getAnnotations();
        } else {
            ias = document.getAnnotations(inputASName);
        }
        try {
			String ident= "_"+inputASName+"_"+UUID.randomUUID().toString()+".xml";
			File parserFile= new File(prologProgram.toURI());
            File toPrologFile= new File(tempDir+"/toProlog"+ident);
            File fromPrologFile= new File(tempDir+"/fromProlog"+ident);
            File fromPrologChangesFile= null;
            if(changesFlag) {
                fromPrologChangesFile= new File(tempDir+"/changes"+ident);
            }
            writeToProlog(ias, toPrologFile);
            callProlog(parserFile, toPrologFile, fromPrologFile, fromPrologChangesFile);
            AnnotationSet oas = document.getAnnotations(outputASName);
            readFromProlog(oas, fromPrologFile);
            if(!retainTempFiles&&toPrologFile.exists()) toPrologFile.delete();
            if(!retainTempFiles&&fromPrologFile.exists()) fromPrologFile.delete();
            if(changesFlag) {
                String changesXmlStr= FileUtils.readFileToString(fromPrologChangesFile, "UTF-8");
                document.getFeatures().put("xmlContent", changesXmlStr);
                if(!retainTempFiles) fromPrologChangesFile.delete();
            }
        } catch (IOException ex) {
            Logger.getLogger(Parser.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InvalidOffsetException ex) {
            Logger.getLogger(Parser.class.getName()).log(Level.SEVERE, null, ex);
        } catch (JAXBException ex) {
            Logger.getLogger(Parser.class.getName()).log(Level.SEVERE, null, ex);
        } catch (URISyntaxException ex) {
            Logger.getLogger(Parser.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void writeToProlog(AnnotationSet as, File toPrologFile) throws FileNotFoundException, ExecutionException, JAXBException {
        PortableAnnotationSet pas= new PortableAnnotationSet(as);
        JAXBContext context= JAXBContext.newInstance(PortableAnnotationSet.class);
        Marshaller m = context.createMarshaller();
        m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, Boolean.TRUE);
        m.marshal(pas,toPrologFile);
    }

    public void readFromProlog(AnnotationSet as, File fromPrologFile) throws IOException, JAXBException, InvalidOffsetException {
        JAXBContext context= JAXBContext.newInstance(PortableAnnotationSet.class);
        Unmarshaller um = context.createUnmarshaller();
        PortableAnnotationSet pas= (PortableAnnotationSet) um.unmarshal(fromPrologFile);
        pas.addToAnnotationSet(as);
    }

    public void callProlog(
		File parserFile,
		File in,
		File out,
		File changesOut)
		throws ExecutionException {
		
		// External command and its args
		String argv[]= {
			swiPrologExecutable,
			parserFile.getAbsolutePath(),
			"--",
			in.getAbsolutePath(),
			out.getAbsolutePath(),
			(changesOut==null) ? "" : changesOut.getAbsolutePath()
		};
	
		ProcessManager processManager = new ProcessManager();
		
		try {
		  int exitCode = processManager.runProcess(argv, true);
		  if(exitCode != 0) {
			  throw new ExecutionException("SWI-Prolog error code "+exitCode);
		  }
		}
		catch(IOException e) {
		  ExecutionException ee = new ExecutionException("I/O error executing "+argv[0]);
		  ee.initCause(e);
		  throw ee;
		}
	}

    @Optional
    @RunTime
    @CreoleParameter(comment = "Name of the input annotationSet used")
    public void setInputASName(String setName) {
        this.inputASName = setName;
    }
    public String getInputASName() {
        return inputASName;
    }

    @Optional
    @RunTime
    @CreoleParameter(comment = "Name of the output annotationSet used")
    public void setOutputASName(String setName) {
        this.outputASName = setName;
    }
    public String getOutputASName() {
        return outputASName;
    }

    @RunTime
    @CreoleParameter(comment = "Prolog file to run")
    public void setPrologProgram(URL file) {
        this.prologProgram = file;
    }
    public URL getPrologProgram() {
        return prologProgram;
    }

    @RunTime
    @CreoleParameter(comment = "Whether Prolog creates changes file")
    public void setChangesFlag(Boolean flag) {
        this.changesFlag = flag;
    }
    public Boolean getChangesFlag() {
        return changesFlag;
    }

    // These parameters are declared in the creole.xml
	// so that the default values can be overridden there.
	// We have hidden defaults because we don't want
	// them to get saved when the pipeline is saved
	// The TempDir are SwiPrologExecutable have
	// OS-dependent defaults.
    public void setTempDir(String dir) {
        this.overrideTempDir = dir;
    }
    public String getTempDir() {
        return overrideTempDir;
    }

    public void setSwiPrologExecutable(String file) {
        this.overrideSwiPrologExecutable = file;
    }
    public String getSwiPrologExecutable() {
        return this.overrideSwiPrologExecutable;
    }

    public void setRetainTempFiles(Boolean rtf) {
        this.overrideRetainTempFiles = rtf;
    }
    public Boolean getRetainTempFiles() {
        return this.overrideRetainTempFiles;
    }

} // class Parser
