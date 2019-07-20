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
 * HDFSDemo
 */
public class HDFSDemo {

    private FileSystem fs;

    @Before
    public void before() throws IOException, InterruptedException, URISyntaxException {

        //Configuration
        Configuration configuration = new Configuration();
        //FileSystem
        fs = FileSystem.get(new URI("hadoop101:9000"), configuration, "tian");
        
    }

    @After
    public void after() throws IOException {
        
        //关闭资源
        if(fs!=null)
        fs.close();
    }

    /**
     * mkdir test
     * 
     * @throws IOException
     * @throws IllegalArgumentException
     */
    @Test
    public void mkdir() throws IllegalArgumentException, IOException {
        
        fs.mkdirs(new Path("/tian/input/"));
    }

    /**
     * uploadfile test
     * 
     * @throws IOException
     * @throws IllegalArgumentException
     */
    @Test
    public void uploadfile() throws IllegalArgumentException, IOException {
        fs.copyToLocalFile(new Path("/tian/input/test.c"), new Path("e:/bak_soft/test.c"));
    }
}