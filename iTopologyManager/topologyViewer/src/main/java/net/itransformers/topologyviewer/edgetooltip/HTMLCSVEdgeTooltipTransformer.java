/*
 * HTMLCSVEdgeTooltipTransformer.java
 *
 * This work is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 *
 * This work is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 * USA
 *
 * Copyright (c) 2010-2016 iTransformers Labs. All rights reserved.
 */

package net.itransformers.topologyviewer.edgetooltip;

import net.itransformers.topologyviewer.config.models.TooltipType;
import edu.uci.ics.jung.io.GraphMLMetadata;
import org.apache.commons.collections15.Transformer;
import org.apache.log4j.Logger;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class HTMLCSVEdgeTooltipTransformer extends EdgeTooltipTransformerBase{
    static Logger logger = Logger.getLogger(HTMLCSVEdgeTooltipTransformer.class);

    public HTMLCSVEdgeTooltipTransformer(TooltipType tooltipType, Map<String, GraphMLMetadata<String>> edgeMetadatas) {
        super(tooltipType, edgeMetadatas);
    }

    public String transform(String edge) {
        try {
             StringBuilder sb = new StringBuilder();
            sb.append("<html>");
             Set<String> valueSet = new HashSet<String>();
             GraphMLMetadata<String> stringGraphMLMetadata = edgeMetadatas.get(tooltipType.getDataKey());
             if (stringGraphMLMetadata == null) {
                logger.error("Unable find tooltip edgeMetadata for key: "+tooltipType.getDataKey());
                 return "";
             }
             Transformer<String, String> transformer = stringGraphMLMetadata.transformer;
             final String value = transformer.transform(edge);
             if (value != null && !sb.toString().contains(value)){
                 sb.append(value);
             }
            sb.append(valueSet);

            sb.append("</html>");
            return sb.toString().replaceAll("\\[\\]","");
        } catch (RuntimeException rte) {
            rte.printStackTrace();
            throw rte;
        }
    }
}
