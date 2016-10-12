/*
 * StartDiscoveryMenuHandler.java
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

package net.itransformers.topologyviewer.menu.handlers;

import net.itransformers.resourcemanager.ResourceManager;
import net.itransformers.resourcemanager.ResourceManagerFactory;
import net.itransformers.topologyviewer.dialogs.discovery.DiscoveryManagerDialogV2;
import net.itransformers.topologyviewer.gui.TopologyManagerFrame;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * Date: 12-4-27
 * Time: 23:30
 * To change this template use File | Settings | File Templates.
 */
public class StartDiscoveryMenuHandler implements ActionListener {

    private TopologyManagerFrame frame;

    public StartDiscoveryMenuHandler(TopologyManagerFrame frame) throws HeadlessException {
        this.frame = frame;
    }

    @Override
    public void actionPerformed(ActionEvent e) {
        DiscoveryManagerDialogV2 dialog = new DiscoveryManagerDialogV2(frame,
                frame.getPath(),
                frame.getProjectType());
        dialog.setDefaultCloseOperation(JDialog.DISPOSE_ON_CLOSE);
        dialog.setVisible(true);

    }


}
