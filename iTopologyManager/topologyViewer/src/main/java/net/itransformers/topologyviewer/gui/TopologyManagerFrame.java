/*
 * TopologyManagerFrame.java
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

package net.itransformers.topologyviewer.gui;

import net.itransformers.topologyviewer.menu.MenuBuilder;
import net.itransformers.utils.ProjectConstants;
import net.itransformers.utils.graphmledgedefaultresolver.GraphmlEdgeDefaultResolver;
import org.apache.log4j.Logger;

import javax.swing.*;
import java.awt.*;
import java.io.*;
import java.security.AccessControlException;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;


public class TopologyManagerFrame extends JFrame{
    static Logger logger = Logger.getLogger(TopologyManagerFrame.class);
    public static final String VIEWER_PREFERENCES_PROPERTIES = "viewer-preferences.properties";
    private File path;
    private String projectType;
    private String viewerConfig;
    private JTabbedPane tabbedPane;
    private Properties preferences = new Properties();
    Map<String, GraphViewerPanelManager> viewerPanelManagerMap = new HashMap<String, GraphViewerPanelManager>();
    protected GraphViewerPanelManagerFactory graphViewerPanelManagerFactory;

    public TopologyManagerFrame() {
        super("netTransformer");
    }

    public void init() throws IOException {
        this.init(null);
    }
    public void init(File path) throws IOException {
        //super.setIconImage(Toolkit.getDefaultToolkit().getImage("images/logo3.png"));
        File prefsFile = new File(VIEWER_PREFERENCES_PROPERTIES);
        try {
            if (!prefsFile.exists()) {
                if (!prefsFile.createNewFile()){
                    logger.error("Can not create preferences file");
                }
            }
            preferences.load(new FileInputStream(prefsFile));

        } catch (AccessControlException e){
            logger.error(e.getMessage());
        }
        this.path = path;
        createFrame();
        String projectPath = preferences.getProperty("PATH");
        String graphmlPath = preferences.getProperty("GRAPHML_REL_DIR");

        if (projectPath != null) {
            File projectPathFile = new File(projectPath);
            this.doOpenProject(projectPathFile);

            if (graphmlPath != null) {
                File graphmlPathFile = new File(graphmlPath);
                if (graphmlPathFile.exists()) {
                    this.doOpenGraph(graphmlPathFile);
                }
            }
        }
    }

    public GraphViewerPanelManagerFactory getGraphViewerPanelManagerFactory() {
        return graphViewerPanelManagerFactory;
    }

    public void setGraphViewerPanelManagerFactory(GraphViewerPanelManagerFactory graphViewerPanelManagerFactory) {
        this.graphViewerPanelManagerFactory = graphViewerPanelManagerFactory;
    }

    public File getPath() {
        return path;
    }

    public void setPath(File path) {
        this.path = path;
    }

    public String getViewerConfig() {
        return viewerConfig;
    }

    public void setViewerConfig(String viewerConfig) {
        this.viewerConfig = viewerConfig;
    }
    public void setProjectType(String projectType) {
        this.projectType = projectType;
    }
    public String getProjectType() {
        return projectType;
    }

    private void createFrame(){
        tabbedPane = new JTabbedPane();
        this.setExtendedState(Frame.MAXIMIZED_BOTH);
        try {
            this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        } catch (java.security.AccessControlException e){
            e.printStackTrace();
        }
        final Container content = this.getContentPane();

        JMenuBar menuBar = new MenuBuilder().createMenuBar(this);

        content.add(tabbedPane);

        this.setJMenuBar(menuBar);
        this.setMinimumSize(new Dimension(640, 480));
        this.setVisible(true);
        this.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
    }


    public JTabbedPane getTabbedPane() {
        return tabbedPane;
    }

    public Properties getPreferences() {
        return preferences;
    }

    public void doOpenGraph(File selectedFile) {

        this.getPreferences().setProperty(PreferencesKeys.GRAPHML_REL_DIR.name(), selectedFile.getAbsolutePath());

        try {
            this.getPreferences().store(new FileOutputStream(TopologyManagerFrame.VIEWER_PREFERENCES_PROPERTIES), "");
        } catch (IOException e) {
            e.printStackTrace();
        }


        try {
            GraphmlEdgeDefaultResolver graphTypeResolver = new GraphmlEdgeDefaultResolver();
            String graphType = graphTypeResolver.resolveEdgeDefault(selectedFile);
            GraphViewerPanelManager viewerPanelManager =
                    graphViewerPanelManagerFactory.createGraphViewerPanelManager(
                            graphType,
                            projectType,
                            viewerConfig,
                            selectedFile,
                            path,
                            tabbedPane);
            viewerPanelManager.init();
            viewerPanelManagerMap.put(viewerPanelManager.getVersionDir().getAbsolutePath(),viewerPanelManager);
            viewerPanelManager.createAndAddViewerPanel();

        }
         catch (Exception e){
            e.printStackTrace();
            JOptionPane.showMessageDialog(this,"Error creating graph: "+e.getMessage());
        }
    }
    public void doCloseGraph() {

        GraphViewerPanel viewerPanel = (GraphViewerPanel)getTabbedPane().getSelectedComponent();
        if (viewerPanel == null){
            return;
        }
        String absolutePath = viewerPanel.getVersionDir().getAbsolutePath();
        viewerPanelManagerMap.remove(absolutePath);
        JTabbedPane tabbedPane = this.getTabbedPane();
        int count = tabbedPane.getTabCount() ;
        for (int j = count-1 ; j >= 0 ; j--) {
            GraphViewerPanel currentViewerPanel = (GraphViewerPanel) tabbedPane.getComponent(j);
            if (currentViewerPanel.getVersionDir().getAbsolutePath().equals(absolutePath)) tabbedPane.remove(j) ;
        }

    }

    public void doOpenProject(File selectedFile) {

        this.setPath(new File(selectedFile.getParent()));

        if (selectedFile.getName().equals("bgpPeeringMap.pfl")) {
            this.setProjectType(ProjectConstants.mrtBgpDiscovererProjectType);
            this.setName("bgpPeeringMap");
            this.setViewerConfig("topologyViewer/conf/bgpPeeringMap/viewer-config.xml");
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(0).setEnabled(true);
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(1).setEnabled(true);
            this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(4).setEnabled(true);

        }
        if (selectedFile.getName().equals("freeGraph.pfl")) {
            this.setProjectType(ProjectConstants.freeGraphProjectType);

            this.setName("bgpPeeringMap");
            this.setViewerConfig("topologyViewer/conf/freeGraph/viewer-config.xml");
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(0).setEnabled(true);
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(1).setEnabled(true);
            this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(4).setEnabled(true);

        } else if (selectedFile.getName().equals("bgpSnmpPeeringMap.pfl")) {
            this.setProjectType(ProjectConstants.snmpBgpDiscovererProjectType);
            this.setViewerConfig("topologyViewer/conf/bgpPeeringMap/viewer-config.xml");
            //
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(0).setEnabled(true);
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(1).setEnabled(true);

            this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(3).setEnabled(true);

        } else if (selectedFile.getName().equals("netTransformer.pfl")) {
            this.setProjectType(ProjectConstants.snmpProjectType);
            this.setViewerConfig("topologyViewer/discovery/viewer-config.xml");
            //
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(0).setEnabled(true);
            this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(1).setEnabled(true);

            this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(3).setEnabled(true);

        } else {
            JOptionPane.showMessageDialog(this, "Unknown project type");
            return;

        }
        this.setTitle(ProjectConstants.getProjectName(this.getProjectType()));
        this.getRootPane().getJMenuBar().getMenu(1).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(2).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(3).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(4).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(5).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(6).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(7).setEnabled(true);

        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(4).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(5).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(6).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(7).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(8).setEnabled(true);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(9).setEnabled(true);

        this.getPreferences().setProperty(PreferencesKeys.PATH.name(), selectedFile.toString());


        try {
            this.getPreferences().store(new FileOutputStream(TopologyManagerFrame.VIEWER_PREFERENCES_PROPERTIES), "");


        } catch (IOException e1) {
            e1.printStackTrace();
            JOptionPane.showMessageDialog(this, "Can not Store preferences: " + e1.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    public void doCloseProject() {

        setPath(null);
        getTabbedPane().removeAll();
        viewerPanelManagerMap.clear();
        setProjectType("");

        //Disable all main menus except the File and Help
        this.getRootPane().getJMenuBar().getMenu(1).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(2).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(3).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(4).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(5).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(6).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(7).setEnabled(false);

        //Disable most of the components of  File menu (all except the Open Project)

        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(4).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(5).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(6).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(7).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(8).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(0).getMenuComponent(9).setEnabled(false);


        // frame.getRootPane().getJMenuBar().getMenu(4).setEnabled(false);
        //Disable iDiscover menu options
        this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(0).setEnabled(false);
       this.getRootPane().getJMenuBar().getMenu(1).getMenuComponent(1).setEnabled(false);
        //Disable Discoverers settings options

        this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(3).setEnabled(false);
        this.getRootPane().getJMenuBar().getMenu(7).getMenuComponent(4).setEnabled(false);


    }

    public GraphViewerPanelManager getCurrentGraphViewerManager(){
        GraphViewerPanel viewerPanel = (GraphViewerPanel)getTabbedPane().getSelectedComponent();
        if (viewerPanel != null){
            return viewerPanelManagerMap.get(viewerPanel.getVersionDir().getAbsolutePath());
        } else {
            return null;
        }
    }
}

