module statemanip

implicit none

    type state
        integer :: s = 0
        integer :: ns = 0
        integer :: alphas = 0
        integer :: betas = 0
    end type state

contains

    integer function kdelta(x, y) result(output)
        integer, intent(in) :: x
        integer, intent(in) :: y
        if (x .eq. y) then
            output = 1
        else
            output = 0
        end if
        return
    end function kdelta

    subroutine setstate(astate, vs, vn_s, valpha_s, vbeta_s)
        type(state), intent(inout) :: astate
        integer, intent(in) :: vs
        integer, intent(in) :: vn_s
        integer, intent(in) :: valpha_s
        integer, intent(in) :: vbeta_s
        astate%s = vs
        astate%ns = vn_s
        astate%alphas = valpha_s
        astate%betas = vbeta_s
    end subroutine setstate

    function getstate(astate)
        type(state), intent(inout) :: astate
        integer, dimension(4) :: getstate
        getstate(1) = astate%s
        getstate(2) = astate%ns
        getstate(3) = astate%alphas
        getstate(4) = astate%betas
    end function getstate

    function mel(s1, s2)
        implicit none

        type(state), intent(inout) :: s1
        type(state), intent(inout) :: s2

        integer :: Hu, Hl, Hs, Hsp1, Hsm1

        integer :: mel

        integer :: vns1, valphas1, vbetas1
        integer :: vns2, valphas2, vbetas2

        vns1 = s1%ns
        valphas1 = s1%alphas
        vbetas1 = s1%betas

        vns2 = s2%ns
        valphas2 = s2%alphas
        vbetas2 = s2%betas

        if (s1%s .eq. s2%s) then
            if (vns1 .ne. vns2 .or. &
                valphas1 .ne. valphas2 .or. &
                vbetas1 .ne. vbetas2) then
                Hsp1 = kdelta(vns1, vns2) * kdelta(valphas1, valphas2) * &
                        (kdelta(vbetas1, vbetas2 + 1) &
                        + kdelta(vbetas1, vbetas2 - 1))
                
                Hsm1 = kdelta(vns1, vns2) * kdelta(vbetas1, vbetas2) * &
                        (kdelta(valphas1, valphas2 + 1) &
                        + kdelta(valphas1, valphas2 - 1))
                
                Hs = kdelta(vns1, vns2-1) * kdelta(valphas1, valphas2-1) * &
                        kdelta(vbetas1, vbetas2 + 1) + &
                    kdelta(vns1, vns2+1) * kdelta(valphas1, valphas2+1) * &
                        kdelta(vbetas1, vbetas2 - 1)
            else
                Hs = 0
                Hsp1 = 0
                Hsm1 = 0
            end if

            if (vns1 .eq. vns2 .and. &
                valphas1 .eq. valphas2 .and. &
                vbetas1 .eq. vbetas2 .and. s1%s .gt. 2) then
                Hl = 1
            else
                Hl = 0
            end if
            
            mel = Hs + Hsp1 + Hsm1 + Hl
        else
            mel = 0
        end if

    end function mel

    function checkvalidity(s1)
        type(state), intent(inout) :: s1
        integer :: checkvalidity
        checkvalidity = 1
        if (s1%s .lt. 2 .or. s1%ns .lt. 0) then
            checkvalidity = 0
        end if
        if (s1%s .eq. 0 .and. s1%ns .eq. 0 .and. &
            s1%alphas .eq. 0 .and. s1%betas .eq. 0) then
            checkvalidity = 0
        end if
        if (s1%s - 1 .lt. s1%ns - s1%alphas) then
            checkvalidity = 0
        end if
        if (s1%alphas .gt. s1%ns) then
            checkvalidity = 0
        end if
    end function

    function relegate0(s1)
        type(state), intent(inout) :: s1
        type(state) :: relegate0
        integer :: sm1, nsm1, alphasm1, betasm1
        ! if (s1%s - 1 .gt. s1%ns - (0+s1%alphas)) then
        !     call setstate(relegate0, &
        !         (s1%s)-1, s1%ns - (1+s1%alphas), 0, s1%alphas)
        ! end if
        sm1 = s1%s - 1
        betasm1 = s1%alphas
        alphasm1 = 0
        nsm1 = s1%ns - betasm1
        call setstate(relegate0, sm1, nsm1, alphasm1, betasm1)
    end function

    function relegate1(s1)
        type(state), intent(inout) :: s1
        type(state) :: relegate1
        integer :: sm1, nsm1, alphasm1, betasm1
        ! if (s1%s .gt. s1%ns - (s1%alphas)) then
        !     call setstate(relegate1, &
        !         (s1%s)-1, s1%ns - (s1%alphas), 1, s1%alphas)
        ! end if
        sm1 = s1%s - 1
        betasm1 = s1%alphas
        alphasm1 = 1
        nsm1 = s1%ns - betasm1
        call setstate(relegate1, sm1, nsm1, alphasm1, betasm1)
    end function

    function getlstate(s1)
        type(state), intent(inout) :: s1
        character(len=10) :: getlstate
        character(len=2) :: the_s
        character(len=2) :: k
        character(len=2) :: the_ns

        write(the_s, "(A2)") s1%s
        write(the_ns, "(A2)") s1%ns

        if (s1%alphas .eq. 0 .and. s1%betas .eq. 0) then
            write(k, "(A)") " a"
        end if

        if (s1%alphas .eq. 0 .and. s1%betas .eq. 1) then
            write(k, "(A)") " b"
        end if

        if (s1%alphas .eq. 1 .and. s1%betas .eq. 0) then
            write(k, "(A)") " c"
        end if

        if (s1%alphas .eq. 1 .and. s1%betas .eq. 1) then
            write(k, "(A)") " d"
        end if

        write(getlstate, "(I2, A2, I2)") s1%s, k, s1%ns
    
    end function


    recursive subroutine findmels(s1, s2)
        type(state), intent(inout) :: s1
        type(state), intent(inout) :: s2

        type(state) :: s1s0
        type(state) :: s1s1
        type(state) :: s2s0
        type(state) :: s2s1

        integer :: meltest = 0

        character(len=100) :: fmt

        fmt = "(4A, I2)"

        meltest = mel(s1, s2)

        if (checkvalidity(s1) .eq. 1 .and. &
        checkvalidity(s2) .eq. 1) then
            write (*,fmt) getlstate(s1) , char(9), getlstate(s2),&
             char(9), meltest
        end if

        s1s0 = relegate0(s1)
        s1s1 = relegate1(s1)
        s2s0 = relegate0(s2)
        s2s1 = relegate1(s2)

        if (meltest .ne. 0) then
            if (checkvalidity(s1s0) .eq. 1 .and. &
            checkvalidity(s2s0) .eq. 1) then
                call findmels(s1s0, s2s0)
            end if

            if (checkvalidity(s1s0) .eq. 1 .and. &
            checkvalidity(s2s1) .eq. 1) then
                call findmels(s1s0, s2s1)
            end if

            if (checkvalidity(s1s1) .eq. 1 .and. &
            checkvalidity(s2s0) .eq. 1) then
                call findmels(s1s1, s2s0)
            end if

            if (checkvalidity(s1s1) .eq. 1 .and. &
            checkvalidity(s2s1) .eq. 1) then
                call findmels(s1s1, s2s1)
            end if

        end if

    end subroutine findmels

end module statemanip