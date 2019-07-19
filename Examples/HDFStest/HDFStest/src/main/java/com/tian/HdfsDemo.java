package com.tian;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * HdfsDemo
 */
public class HdfsDemo {


    private FileSystem fs;
    @Before
    public void before() throws IOException, InterruptedException, URISyntaxException{

        //Configuration
        Configuration configuration = new Configuration();

        fs = FileSystem.get(new URI("hdfs://hadoop101:9000"), configuration, "tian");
        
    }

    @After
    public void after() throws IOException {

        if(fs!=null)
        fs.close();
    }

    @Test
    public void testConn() throws IllegalArgumentException, IOException {
        
        fs.mkdirs(new Path("/hdfs/code/input"));
    }

    @Test
    public void testMkdir() throws IllegalArgumentException, IOException {
        
        fs.mkdirs(new Path("/hd/tian/input"));
    }

    
}