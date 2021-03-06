package net.itransformers.xmlParameterFactory;


import net.itransformers.parameterfactoryapi.ParameterFactory;
import net.itransformers.parameterfactoryapi.ParameterFactoryBuilder;
import net.itransformers.parameterfactoryapi.ParameterFactoryException;
import net.itransformers.parameterfactoryapi.ParameterFactoryManger;
import net.itransformers.parameterfactoryapi.model.*;
import net.itransformers.parameterfactoryapi.util.JaxbMarshalar;

import javax.xml.bind.JAXBException;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by niau on 1/10/17.
 */
public class XmlParameterFactoryManager implements ParameterFactoryManger {
    private File paramFactoriesFile;
    private File paramFactoriesElementsFile;

    private Map<String, ParameterFactory> parameterFactories;
    ParamFactoriesType paramFactoriesType;


    public XmlParameterFactoryManager(File paramFactoriesFile, File paramFactoriesElements) {
        this.paramFactoriesFile = paramFactoriesFile;
        this.paramFactoriesElementsFile = paramFactoriesElements;
        try {
            init();
        } catch (IOException e) {
            e.printStackTrace();
        }


    }

    private void init() throws IOException {

        Map<String, ParamFactoryType> parameterFactoryTypeMap = new HashMap<String, ParamFactoryType>();
        Map<String, TypeType> parameterFactoryElementTypesMap = new HashMap<String, TypeType>();
        ParameterFactoryBuilder parameterFactoryBuilder;

        FileInputStream is = null;
        try {

            is = new FileInputStream(this.paramFactoriesFile);
            paramFactoriesType = JaxbMarshalar.unmarshal(ParamFactoriesType.class, is);
            for (ParamFactoryType paramFactoryType : paramFactoriesType.getParamFactory()) {

                parameterFactoryTypeMap.put(paramFactoryType.getName(), paramFactoryType);
            }


            is = new FileInputStream(this.paramFactoriesElementsFile);
            ParamFactoriesConfigType paramFactoriesConfigType = JaxbMarshalar.unmarshal(ParamFactoriesConfigType.class, is);
            ParamFactoryElementTypesType paramFactoryTypesType = paramFactoriesConfigType.getParamFactoryElementTypes();

            for (TypeType typeOfParameterFactory : paramFactoryTypesType.getType()) {

                parameterFactoryElementTypesMap.put(typeOfParameterFactory.getName(), typeOfParameterFactory);
            }
            parameterFactoryBuilder = new ParameterFactoryBuilder(parameterFactoryTypeMap, parameterFactoryElementTypesMap);
            parameterFactories = parameterFactoryBuilder.buildParameterFactories();

        } catch (JAXBException e) {
            e.printStackTrace();
        } finally {
            if (is != null) is.close();
        }

    }


    @Override
    public ParameterFactory getParameterFactory(String name) {
        return parameterFactories.get(name);
    }

    @Override
    public Map<String, ParameterFactory> getParameterFactories() {
        return parameterFactories;
    }

    @Override
    public ParamFactoriesType getParamFactoryTypes() {
        return paramFactoriesType;
    }

    @Override
    public ParamFactoryType getParamFactoryType(String name) {

        for(ParamFactoryType paramFactoryType : paramFactoriesType.getParamFactory())
            if (paramFactoryType.getName().equals(name))
                return paramFactoryType;

        throw new ParameterFactoryException("Parameter factory "+name+" not found!!!");
    }

    @Override
    public ParamFactoryElementType getParamFactoryElementType(String name, String type) {

        for(ParamFactoryType paramFactoryType : paramFactoriesType.getParamFactory())
            if (paramFactoryType.getName().equals(name)) {

                List<ParamFactoryElementType> paramFactoryElements = paramFactoryType.getParamFactoryElement();
                for (ParamFactoryElementType paramFactoryElement : paramFactoryElements) {
                    if (paramFactoryElement.getType().equals(type)) {
                        return paramFactoryElement;
                    }

                }

            }


        throw new ParameterFactoryException("Parameter factoryElement with type=" +type+ " in parameter factory "+name+" has not been found!!!");

    }


}
