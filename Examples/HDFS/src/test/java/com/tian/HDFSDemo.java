package com.tian;

import java.io.FileNotFoundException;
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

        // Configuration
        Configuration configuration = new Configuration();
        // FileSystem
        fs = FileSystem.get(new URI("hadoop101:9000"), configuration, "tian");

    }

    @After
    public void after() throws IOException {

        // 关闭资源
        if (fs != null)
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

        fs.copyToLocalFile(new Path("e:/bak_soft/test.c"), new Path("/tian/input/test.c"));

    }

    /**
     * download test
     * 
     * @throws IOException
     * @throws IllegalArgumentException
     */
    @Test
    public void download() throws IllegalArgumentException, IOException {

        /**
         * 参数优先级由高到低 客户端代码设置的值 ClassPath下的用户自定义的配置文件 服务器默认的配置
         */
        fs.copyToLocalFile(new Path("/tian/input/test.c"), new Path("e:/bak_soft/test.c"));
        //false不删除源文件
        fs.copyToLocalFile(false, new Path("/tian/input/test.c"), new Path("e:/bak_soft/test.c"));
        //true开启文件检查
        fs.copyToLocalFile(false, new Path("/tian/input/test.c"), new Path("e:/bak_soft/test.c"), true);

    }

    /**
     * del dir
     * 
     * @throws IOException
     * @throws IllegalArgumentException
     */
    @Test
    public void deldir() throws IllegalArgumentException, IOException {

        //方法已过期
        //fs.delete(new Path("test1"));
        //级联删除
        fs.delete(new Path("/testpath/"), true);
    }

    /**
     * rename
     * 
     * @throws IOException
     * @throws IllegalArgumentException
     */
    @Test
    public void rename() throws IllegalArgumentException, IOException {
        fs.rename(new Path("renametest"), new Path("renamed"));
    }

    /**
     * list file
     * 
     * @throws IOException
     * @throws IllegalArgumentException
     * @throws FileNotFoundException
     */
    public void listFile() throws FileNotFoundException, IllegalArgumentException, IOException {
        
        //获取文件详情
        fs.listFiles(new Path("/"), true);
    }
}