// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.0;

// create a twitter contract
// create a mapping between user and tweet


contract Twitter is Ownable {
    uint16 public MAX_TWEET_LENGTH = 200;
    uint256 currentTweetId = 0; // global unique id

    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    mapping (address => mapping (uint256 => Tweet)) private tweets;
    mapping (address => uint256) private tweetCount;

    event TweetCreated(uint256 id, address author, string content, uint256 timestamp);
    event TweetLiked(uint256 id, address author, uint256 likeCount, address liker);
    event TweetUnliked(uint256 id, address author, uint256 likeCount, address liker);
    
    constructor() Ownable(msg.sender) {
    }

    // modifier onlyOwner() {
    //     require(OWNER == msg.sender, "Only owner can change the tweet length");
    //     _;
    // }

    function createTweet(string memory _input) public {
        require(bytes(_input).length <= MAX_TWEET_LENGTH, "Tweet content is lengthy");

        Tweet memory newTweet = Tweet({
            id: currentTweetId,
            author: msg.sender,
            content: _input,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender][currentTweetId] = newTweet;
        
        emit TweetCreated(currentTweetId, newTweet.author, newTweet.content, newTweet.timestamp);
        
        currentTweetId++;
        tweetCount[msg.sender]++;
    }

    function getTweet(uint _i) public view returns (Tweet memory){
        return tweets[msg.sender][_i];
    }

    function getAllTweets(address owner) public view returns (Tweet[] memory) {
        uint256 count = tweetCount[owner];
        Tweet[] memory allTweets = new Tweet[](count);
        for (uint256 i = 0; i < count; i++) {
            allTweets[i] = tweets[owner][i];
        }
        
        return allTweets;
    }

    function changeTweetLength(uint16 _input) public onlyOwner {
        MAX_TWEET_LENGTH = _input;
    }

    function getOwner() public view returns (address) {
        return Ownable.owner();
    }

    function likeTweet(uint256 _id, address _author) external {
        require(tweets[_author][_id].id == _id, "Tweet does not exist");
        tweets[_author][_id].likes++;

        emit TweetLiked(_id, _author, tweets[_author][_id].likes, msg.sender);
    }

    function unlikeTweet(uint256 _id, address _author) external {
        require(tweets[_author][_id].likes > 0, "Likes have not added yet");
        tweets[_author][_id].likes--;

        emit TweetUnliked(_id, _author, tweets[_author][_id].likes, msg.sender);
    }

    function getTotalLikes(address _author) public view returns (uint256) {
        uint256 totalLikes = 0;
        uint256 tweetCountForUser = tweetCount[_author];
        for (uint i = 0; i < tweetCountForUser; i++) {
            totalLikes += tweets[_author][i].likes;
        }

        return totalLikes;
    }
}