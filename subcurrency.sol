// 이더리움을 활용하여 smart contract로 하위 화폐 즉 크립토코인을 만들어보기.
// SPDX-License-Identifier: MIT

// Rule
// 작성자(계약작성자)만 새코인은 만들 수 있다.
// 코인을 전송하는 것은 누구나 할 수 있다.
pragma solidity >= 0.8.0 <0.9.0;

contract Coin{
    // 변수에 public을 설정하는 이유는 다른계약이 변수에 접근할수 있게 하기 때문이다.
    //두개의 상태변수를 만들것이다 민팅할토큰 하나는 잔액을 ㅅㄹ정할 것이다.
    address public minter; // 민팅 토큰 담을 address 변수
    mapping (address => uint) public balances;

    // 코인을 송금하는 함수를 만들 때 이 함수를 생략 할 수 있다. 
    //이것을 통해 클라이언트가 반응 할 때 이것이 어디서 왔고 어디로 가고 금액은 얼마인지 볼 수 있고
    // send 함수를 생성할때 이 이벤트를 생략 할 수 있다.
    /* 
        이벤트는 매개변수를 저장한다. address from, uint amount 이두개를 저장한다.
        이 로그는 이더리움 블록체인에 저장된다.
        계약이 존재할 때까지 계약 주소를 통해 액세스할 수 있습니다.
        send 함수를 실행한 후 Sent 이벤트를 발생시켜줘야한다.
    */
    event Sent(address from, address to, uint amount);

    // constructor(생성자)는 오직 계약을 배포할 때 만 실행된다.
    constructor(){
        minter = msg.sender; // 계약 발신자를 반환하는 전역 변수 msg.sender

    }

    // 새로운 코인을 만들고 주소로 보내려고 하는 함수. 즉 새로운 토큰을 생성하는 것을 민팅이라고함.
    // 소유자만 해당 코인을 보낼수 있게 할것이다.
    // 인자값으론 수신자 receiver, 금액인 amount를 설정할 것이다.
    // 민팅을 할수 있는사람은 계약 생성자 계약서를 Deploy한 minter만이 실행할 수 있다.
    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);   // 보안 프로토콜 ( mint를 실행하는 주소와 계약서를 배포한 사람이 같아야만 실행 가능하도록 )
        balances[receiver] += amount;
    }

    // 잔액부족 알림 request 송금할 금액, 잔액을 나타내는 available
    error insufficientBalance(uint requested, uint available);

    // msg.sender은 함수를 호출한 지갑주소로 설정된다.
    // 기존 주소로 얼마든지 코인을 송금할 수 있는 함수를 만들어 보자.
    function send(address receiver, uint amount) public {
        // 잔액인 특정 금액보다 높아야 이 함수를 실행 할 수 있도록 require 해야한다.
        if(amount > balances[msg.sender]) // 송금할 금액이 내 잔액보다 크다면 에러를 발생시킨
        revert insufficientBalance({ // if문에 걸리면 sending하지 않고 error 메시지 발생시킴
            requested: amount,
            available: balances[msg.sender]
        });
        balances[msg.sender] -= amount;
        balances[receiver] += amount;   
        emit Sent(msg.sender, receiver, amount); //Sent 이벤트 발생시키기 키워드 - emit
    }

}
