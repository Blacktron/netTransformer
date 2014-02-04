//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, vhudson-jaxb-ri-2.1-2 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2014.02.03 at 10:41:19 PM EET 
//


package net.itransformers.topologyviewer.config;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.XmlValue;


/**
 * <p>Java class for edgeStrokeType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="edgeStrokeType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="data" maxOccurs="unbounded" minOccurs="0">
 *           &lt;complexType>
 *             &lt;simpleContent>
 *               &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
 *                 &lt;attribute name="key" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *               &lt;/extension>
 *             &lt;/simpleContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/sequence>
 *       &lt;attribute name="dash" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="width" type="{http://www.w3.org/2001/XMLSchema}float" />
 *       &lt;attribute name="dash_phase" type="{http://www.w3.org/2001/XMLSchema}float" default="0.0" />
 *       &lt;attribute name="miterlimit" type="{http://www.w3.org/2001/XMLSchema}float" />
 *       &lt;attribute name="join" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="cap" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "edgeStrokeType", propOrder = {
    "data"
})
public class EdgeStrokeType {

    protected List<EdgeStrokeType.Data> data;
    @XmlAttribute(name = "dash")
    protected String dash;
    @XmlAttribute(name = "width")
    protected Float width;
    @XmlAttribute(name = "dash_phase")
    protected Float dashPhase;
    @XmlAttribute(name = "miterlimit")
    protected Float miterlimit;
    @XmlAttribute(name = "join")
    protected Integer join;
    @XmlAttribute(name = "cap")
    protected Integer cap;

    /**
     * Gets the value of the data property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the data property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getData().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link EdgeStrokeType.Data }
     * 
     * 
     */
    public List<EdgeStrokeType.Data> getData() {
        if (data == null) {
            data = new ArrayList<EdgeStrokeType.Data>();
        }
        return this.data;
    }

    /**
     * Gets the value of the dash property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDash() {
        return dash;
    }

    /**
     * Sets the value of the dash property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDash(String value) {
        this.dash = value;
    }

    /**
     * Gets the value of the width property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getWidth() {
        return width;
    }

    /**
     * Sets the value of the width property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setWidth(Float value) {
        this.width = value;
    }

    /**
     * Gets the value of the dashPhase property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public float getDashPhase() {
        if (dashPhase == null) {
            return  0.0F;
        } else {
            return dashPhase;
        }
    }

    /**
     * Sets the value of the dashPhase property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setDashPhase(Float value) {
        this.dashPhase = value;
    }

    /**
     * Gets the value of the miterlimit property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getMiterlimit() {
        return miterlimit;
    }

    /**
     * Sets the value of the miterlimit property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setMiterlimit(Float value) {
        this.miterlimit = value;
    }

    /**
     * Gets the value of the join property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getJoin() {
        if (join == null) {
            return  0;
        } else {
            return join;
        }
    }

    /**
     * Sets the value of the join property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setJoin(Integer value) {
        this.join = value;
    }

    /**
     * Gets the value of the cap property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getCap() {
        if (cap == null) {
            return  0;
        } else {
            return cap;
        }
    }

    /**
     * Sets the value of the cap property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCap(Integer value) {
        this.cap = value;
    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;simpleContent>
     *     &lt;extension base="&lt;http://www.w3.org/2001/XMLSchema>string">
     *       &lt;attribute name="key" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
     *     &lt;/extension>
     *   &lt;/simpleContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "value"
    })
    public static class Data {

        @XmlValue
        protected String value;
        @XmlAttribute(name = "key", required = true)
        protected String key;

        /**
         * Gets the value of the value property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getValue() {
            return value;
        }

        /**
         * Sets the value of the value property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setValue(String value) {
            this.value = value;
        }

        /**
         * Gets the value of the key property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getKey() {
            return key;
        }

        /**
         * Sets the value of the key property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setKey(String value) {
            this.key = value;
        }

    }

}
