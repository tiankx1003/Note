package com.tian;


import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.BlockLocation;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.LocatedFileStatus;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.fs.RemoteIterator;
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
        fs = FileSystem.get(new URI("hdfs://hadoop101:9000"), configuration, "tian");

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

        fs.copyFromLocalFile(new Path("d:/hdfs/test.c"), new Path("/tian/input/test.c"));

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
        // fs.copyToLocalFile(new Path("/tian/input/test.c"), new Path("e:/bak_soft/test.c"));
        //false不删除源文件
        // fs.copyToLocalFile(false, new Path("/tian/input/test.c"), new Path("e:/bak_soft/test.c"));
        //true关闭文件检查
        fs.copyToLocalFile(false, new Path("/tian/input/test.c"), new Path("d:/hdfs/test.c"), true);

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
        // fs.delete(new Path("/testdelpath/"));
        //级联删除
        fs.delete(new Path("/testdelpath/"), true);
    }

    /**
     * rename
     * 
     * @throws IOException
     * @throws IllegalArgumentException
     */
    @Test
    public void rename() throws IllegalArgumentException, IOException {
        fs.rename(new Path("/tian/input/renamed.c"), new Path("/tian/input/test.c"));
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
        RemoteIterator<LocatedFileStatus> listFiles = fs.listFiles(new Path("/"), true);

        while(listFiles.hasNext()){
            LocatedFileStatus status = listFiles.next();

            //输出详情
            //文件名称
            System.out.println(status.getPath().getName());
            //长度
            System.out.println(status.getLen());
            //权限
            System.out.println(status.getPermission());
            //分组
            System.out.println(status.getGroup());

            //获取文件存储的块信息
            BlockLocation[] blockLocations = status.getBlockLocations();

            for (BlockLocation blockLocation : blockLocations){

                //获取块存储的主机节点
                String[] hosts = blockLocation.getHosts();

                for (String host : hosts) {
                    System.out.println(host);
                }
            }
        }
    }

    /**
     * judge file or dir
     * 
     * @throws IOException
     * @throws IllegalArgumentException
     * @throws FileNotFoundException
     */
    @Test
    public void listStatus() throws FileNotFoundException, IllegalArgumentException, IOException {

        //判断是文件还是文件夹

        FileStatus[] listStatus = fs.listStatus(new Path("/"));

        for (FileStatus filesStatus : listStatus) {
            if(filesStatus.isFile())
            System.out.println("f:"+filesStatus.getPath().getName());
            else
            System.out.println();
        }
    }


    /**
     * test print "Hello World!"
     */
    @Test
    public void hello() {
        System.out.println("Hello World!");
    }
}