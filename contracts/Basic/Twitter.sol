// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.0;

// 2️⃣ Add a getProfile() function to the interface ✅ 
// 3️⃣ Initialize the IProfile in the contructor ✅ 
// HINT: don't forget to include the _profileContract address as a input 
// 4️⃣ Create a modifier called onlyRegistered that require the msg.sender to have a profile ✅
// HINT: use the getProfile() to get the user
// HINT: check if displayName.length > 0 to make sure the user exists
// 5️⃣ ADD the onlyRegistered modified to createTweet, likeTweet, and unlikeTweet function ✅

interface IProfile {
    struct UserProfile {
        string displayName;
        string bio;
    }
    
    function setProfile(string memory _displayName, string memory _bio) external;
    function getProfile(address _user) external view returns (UserProfile memory);

}

contract Twitter is Ownable {
    uint16 MAX_TWEET_LENGTH = 200;
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

    IProfile profileContract;

    event TweetCreated(uint256 id, address author, string content, uint256 timestamp);
    event TweetLiked(uint256 id, address author, uint256 likeCount, address liker);
    event TweetUnliked(uint256 id, address author, uint256 likeCount, address liker);
    
    constructor(address _profileContract) Ownable(msg.sender) {
        profileContract = IProfile(_profileContract);
    }

    // modifier onlyOwner() {
    //     require(OWNER == msg.sender, "Only owner can change the tweet length");
    //     _;
    // }

    modifier onlyRegistered() {
        require(bytes(profileContract.getProfile(msg.sender).displayName).length > 0, "User does not have a profile");
        _;
    }

    function createTweet(string memory _input) public onlyRegistered {
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

    function likeTweet(uint256 _id, address _author) external onlyRegistered {
        require(tweets[_author][_id].id == _id, "Tweet does not exist");
        tweets[_author][_id].likes++;

        emit TweetLiked(_id, _author, tweets[_author][_id].likes, msg.sender);
    }

    function unlikeTweet(uint256 _id, address _author) external onlyRegistered {
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